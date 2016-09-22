class Recipient < Organisation

  RECOMMENDATION_THRESHOLD = 1
  MAX_FREE_LIMIT = 3
  RECOMMENDATION_LIMIT = 6

  has_many :proposals
  has_many :funds, -> { distinct }, through: :proposals
  has_many :countries, -> { distinct }, through: :proposals
  has_many :districts, -> { distinct }, through: :proposals
  has_many :eligibilities, dependent: :destroy
  has_many :restrictions, through: :eligibilities
  accepts_nested_attributes_for :eligibilities

  has_many :grants # TODO: deprecated
  has_many :features, dependent: :destroy # TODO: deprecated
  has_many :recipient_funder_accesses # TODO: deprecated
  has_one :recipient_attribute # TODO: deprecated
  alias_method :attribute, :recipient_attribute # TODO: deprecated

  def subscribe!
    self.subscription.update_attribute(:active, true)
  end

  def is_subscribed?
    self.subscription.active?
  end

  def can_unlock_funder?(funder)
    if self.subscription.active?
      true
    else
      unlocked_funders.size < MAX_FREE_LIMIT
    end
  end

  def unlocked_funds
    funds.where('eligibility IS NOT NULL')
  end

  def locked_funds
    funds.where('eligibility IS NULL')
  end

  def eligible_funds
    unlocked_funds.where('eligibility = ?', 'Eligible')
  end

  def ineligible_funds
    unlocked_funds.where('eligibility = ?', 'Ineligible')
  end

  def unlocked_fund?(fund)
    unlocked_funds.pluck(:id).include?(fund.id)
  end

  def locked_fund?(fund)
    !unlocked_fund?(fund)
  end

  def full_address
    [
      "#{self.street_address}",
      "#{self.region}",
      "#{self.city}",
      "#{self.postal_code}",
      Country.find_by_alpha2(self.country).name
    ].join(", ")
  end

  # TODO: refactor?
  def recent_grants(year=2015)
    self.grants.where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01")
  end

  # TODO: refactor
  def eligibility_count(funder)
    count = 0

    funder.restrictions.uniq.each do |r|
      self.eligibilities.each do |e|
        count += 1 if e.restriction_id == r.id
      end
    end

    count
  end

  def set_eligibility(proposal, fund, eligibility)
    proposal.recommendation(fund).update_attributes(eligibility: eligibility)
  end

  def check_eligibility(proposal, fund)
    self.eligibility_restrictions(fund).pluck(:eligible).include?(false) ?
      self.set_eligibility(proposal, fund, 'Ineligible') :
      self.set_eligibility(proposal, fund, 'Eligible')
  end

  def check_eligibilities
    self.recipient_funder_accesses.each do |unlocked_funder|
      funder = Funder.find(unlocked_funder.funder_id)
      self.check_eligibility(funder)
    end
  end

  def get_funders_by_eligibility(eligibility)
    Funder.find(self.recommendations.where(eligibility: eligibility).pluck(:funder_id))
  end

  def ineligible?(funder)
    return true if self.load_recommendation(funder).eligibility == 'Ineligible'
  end

  def eligibility_restrictions(fund)
    Eligibility.where(
      recipient_id: self,
      restriction_id: fund.restrictions
    ).order(:id)
  end

  def has_proposal? # refactor?
    proposals.count > 0
  end

  def transferred? # refactor?
    proposals.where(state: 'transferred').count > 0
  end

  def incomplete_proposals? # refactor?
    proposals.where(state: 'initial').count > 0
  end

  def incomplete_first_proposal?
    proposals.count == 1 && proposals.last.state != 'complete'
  end

  def profile_for_migration?
    proposals.count < 1 && profiles.where(state: 'complete').count > 0
  end

  # TODO: refactor
  def questions_remaining?(funder)
    self.eligibility_count(funder) < funder.restrictions.uniq.count
  end

  def restriction_truthy(restriction)
    if restriction.invert
      [['Yes', true],['No', false]]
    else
      [['Yes', false],['No', true]]
    end
  end

  def recommended_funds # TODO: refactor to proposal
    self.proposals.last.funds
      .where('recommendations.total_recommendation >= ?', RECOMMENDATION_THRESHOLD)
      .order('recommendations.total_recommendation DESC', 'funds.name')
  end

  def recommended_with_eligible_funds # TODO: refactor  to proposal
    fund_ids = recommended_funds
      .pluck(:fund_id)
      .take(RECOMMENDATION_LIMIT)
    recommended_funds
      .where(id: fund_ids)
      .where('eligibility is NULL OR eligibility != ?', 'Ineligible')
  end

  def recommended_fund?(fund) # TODO: refactor to proposal
    recommended_funds.pluck(:fund_id).take(RECOMMENDATION_LIMIT).include?(fund.id)
  end

  def similar_funders(funder)
    array = Funder.joins(:recommendations).where("recipient_id = ?", self.id).order("recommendations.score DESC, name ASC").to_a

    array[(array.index(funder)+1)..(array.index(funder)+7)].sample(3)
  end

  def set_boolean(profile, proposal, category, field)
    return proposal[field] = profile.beneficiaries
              .where(category: category)
              .count > 1 ? true : false
  end

  def get_age_segment(age, type='from')
    result = nil
    AgeGroup.order(id: :desc).pluck(:age_from, :age_to).take(7).each do |from, to|
      result = type == 'from' ? from : to if age >= from && age <= to
    end
    return result
  end

  def transfer_data(profile, proposal)
    # beneficiaries
    set_boolean(profile, proposal, 'People', :affect_people)
    set_boolean(profile, proposal, 'Other', :affect_other)

    if proposal.affect_people?
      if profile.age_groups.present?
        proposal.age_group_ids = profile.age_group_ids
      else
        age_ids = AgeGroup.where('age_from >= ? AND age_to <= ?',
                                  get_age_segment(profile.min_age),
                                  get_age_segment(profile.max_age, 'to')).pluck(:id)
        age_ids + [AgeGroup.first.id] if age_ids.count > 7
        proposal.age_group_ids = age_ids
      end
    end

    proposal.beneficiaries_other_required = profile.beneficiaries_other_required
    proposal.beneficiaries_other = profile.beneficiaries_other
    proposal.affect_other = true if proposal.beneficiaries_other_required?

    # implementations
    proposal.implementation_ids = profile.implementation_ids
    proposal.implementations_other_required = profile.implementations_other_required
    proposal.implementations_other = profile.implementations_other
  end

  def transfer_profile_to_existing_proposal(profile, proposal)
    if proposal.initial? || proposal.transferred?
      transfer_data(profile, proposal)
      proposal.check_affect_geo
      proposal.state = 'transferred'
      proposal.valid?
    end
  end

  def transfer_profile_to_new_proposal(profile, proposal)
    if profile_for_migration?
      transfer_data(profile, proposal)

      # beneficiaries
      proposal.beneficiary_ids = profile.beneficiary_ids
      proposal.gender = profile.gender if proposal.affect_people?

      # location
      proposal.country_ids = profile.country_ids
      proposal.district_ids = profile.district_ids
      proposal.check_affect_geo

      proposal.valid?
    end
  end

end
