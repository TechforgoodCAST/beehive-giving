class Recipient < Organisation
  RECOMMENDATION_THRESHOLD = 1
  MAX_FREE_LIMIT = 3
  RECOMMENDATION_LIMIT = 6

  has_many :proposals
  has_many :funds, -> { distinct }, through: :proposals
  has_many :countries, -> { distinct }, through: :proposals
  has_many :districts, -> { distinct }, through: :proposals
  has_many :eligibilities, as: :category, dependent: :destroy
  accepts_nested_attributes_for :eligibilities

  has_many :grants # TODO: deprecated
  has_many :features, dependent: :destroy # TODO: deprecated
  has_many :recipient_funder_accesses # TODO: deprecated

  def subscribe!
    subscription.update_attribute(:active, true)
  end

  def subscribed?
    subscription.active?
  end

  def transferred? # TODO: refactor
    proposals.where(state: 'transferred').count.positive?
  end

  def incomplete_first_proposal?
    proposals.count == 1 && proposals.last.state != 'complete'
  end

  def profile_for_migration?
    @proposal.nil? && profiles.where(state: 'complete').any?
  end

  def set_boolean(profile, proposal, category, field)
    proposal[field] = profile.beneficiaries.where(category: category).count > 1
  end

  def get_age_segment(age, type = 'from')
    result = nil
    AgeGroup.order(id: :desc).pluck(:age_from, :age_to)
            .take(7).each do |from, to|
      result = type == 'from' ? from : to if age >= from && age <= to
    end
    result
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
                                 get_age_segment(profile.max_age, 'to'))
                          .pluck(:id)
        age_ids + [AgeGroup.first.id] if age_ids.count > 7
        proposal.age_group_ids = age_ids
      end
    end

    proposal.beneficiaries_other_required = profile.beneficiaries_other_required
    proposal.beneficiaries_other = profile.beneficiaries_other
    proposal.affect_other = true if proposal.beneficiaries_other_required?

    # implementations
    proposal.implementation_ids = profile.implementation_ids
    proposal.implementations_other_required = profile
                                              .implementations_other_required
    proposal.implementations_other = profile.implementations_other
  end

  def transfer_profile_to_existing_proposal(profile, proposal)
    return unless proposal.initial? || proposal.transferred?
    transfer_data(profile, proposal)
    proposal.check_affect_geo
    proposal.state = 'transferred'
    proposal.valid?
  end

  def transfer_profile_to_new_proposal(profile, proposal)
    return unless profile_for_migration?
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
