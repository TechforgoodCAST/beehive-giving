class Recipient < Organisation

  has_many :grants
  has_many :features, dependent: :destroy
  has_many :enquiries, dependent: :destroy
  has_many :eligibilities, dependent: :destroy
  has_many :restrictions, :through => :eligibilities
  accepts_nested_attributes_for :eligibilities

  has_one :recipient_attribute
  alias_method :attribute, :recipient_attribute

  has_many :recommendations, dependent: :destroy
  has_many :countries, :through => :profiles
  has_many :districts, :through => :profiles
  has_many :beneficiaries, :through => :profiles

  MAX_FREE_LIMIT = 3
  RECOMMENDATION_THRESHOLD = 1
  RECOMMENDATION_LIMIT = 6

  def recipient_profile_limit
    if (Date.today.year - self.founded_on.year) < 4
      (Date.today.year - self.founded_on.year) + 1
    else
      MAX_FREE_LIMIT
    end
  end

  def can_unlock_funder?(funder)
    if self.subscription.present?
      true
    else
      unlocked_funders.size < MAX_FREE_LIMIT && self.profiles.count > 0
    end
  end

  def can_request_funder?(funder, request)
    features.build("#{request}" => true, :funder => funder).valid?
  end

  def unlocked_funder_ids
    RecipientFunderAccess.where(:recipient_id => self.id).map(&:funder_id)
  end

  def unlocked_funders
    Funder.where(:id => unlocked_funder_ids)
  end

  def locked_funders
    unlocked_funder_ids.any? ? Funder.where('id NOT IN (?)', unlocked_funder_ids) : Funder.all
  end

  def locked_funder?(funder)
    !unlocked_funder_ids.include?(funder.id)
  end

  def unlock_funder!(funder)
    RecipientFunderAccess.find_or_create_by({
        :recipient_id => self.id,
        :funder_id => funder.id
    })
  end

  def valid_profile_years
    if profiles.last.year.present?
      a = Profile::VALID_YEARS - profiles.map(&:year)
      a.unshift(profiles.last.year)
    else
      Profile::VALID_YEARS - profiles.map(&:year)
    end
  end

  def can_create_profile?
    profiles.where(year: Date.today.year).count < 1
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

  def eligibility_count(funder)
    count = 0

    funder.restrictions.uniq.each do |r|
      self.eligibilities.each do |e|
        count += 1 if e.restriction_id == r.id
      end
    end

    count
  end

  def funding_stream_eligible?(funding_stream, funder)
    count = 0

    funder.funding_streams.where('label = ?', funding_stream).first.restrictions.each do |r|
      self.eligibilities.each do |e|
        count += 1 if e.restriction_id == r.id && e.eligible == true
      end
    end

    funder.funding_streams.where('label = ?', funding_stream).first.restrictions.count == count ? true : false
  end

  def eligible?(funder)
    count = 0

    funder.funding_streams.each do |f|
      count += 1 if self.funding_stream_eligible?(f.label, funder)
    end

    count > 0 ? true : false
  end

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

  def build_recommendation(funder, score)
    recommendation = Recommendation.where(
      recipient: self,
      funder: funder
    ).first_or_initialize
    recommendation.update_attribute(
      :score, score
    )
  end

  def initial_recommendation
    Funder.all.each do |funder|
      score = 0
      if funder.attributes.any?
        funder.attributes.where('funding_stream = ?', 'All').first.countries.where(alpha2: country).uniq.each { |f| score += 0.1 }
      end
      build_recommendation(funder, score)
    end
  end

  def refined_recommendation
    Funder.where(active_on_beehive: true).each do |funder|
      score = 0

      if funder.attributes.any? && profiles.count > 0
        # Location
        profiles.order('year').last.countries.map(&:alpha2).each do |country|
          score += 0.9 if funder.attributes.where('funding_stream = ?', 'All').first.countries.pluck(:alpha2).uniq.include?(country)
        end

        profiles.order('year').last.districts.map(&:district).each do |district|
          score += 0.1 if funder.attributes.where('funding_stream = ?', 'All').first.districts.pluck(:district).uniq.include?(district)
        end

        # Beneficiaries
        profiles.order('year').last.beneficiaries.map(&:label).each do |beneficiary|
          score += 0.1 if funder.attributes.where('funding_stream = ?', 'All').first.beneficiaries.pluck(:label).uniq.include?(beneficiary)
        end

        if funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_min_age
          score += 0.1 if profiles.order('year').last.min_age >= funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_min_age
        end

        if funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_max_age
          score += 0.1 if profiles.order('year').last.min_age <= funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_max_age
        end

        # Age
        if funder.attributes.where('funding_stream = ?', 'All').first.funded_age_temp
          score += 0.1 if (Date.today - founded_on) >= (funder.attributes.where('funding_stream = ?', 'All').first.funded_age_temp - 2.5) && (Date.today - founded_on) <= (funder.attributes.where('funding_stream = ?', 'All').first.funded_age_temp + 2.5)
        end

        # Finance
        if funder.attributes.where('funding_stream = ?', 'All').first.funded_income_temp
          score += 0.1 if profiles.order('year').last.income >= (funder.attributes.where('funding_stream = ?', 'All').first.funded_income_temp - 25000) && profiles.order('year').last.income <= (funder.attributes.where('funding_stream = ?', 'All').first.funded_income_temp + 25000)
        end

        # Reset for closed funders
        score = 0 if Funder::CLOSED_FUNDERS.include?(funder.name)
      end

      build_recommendation(funder, score)
    end
  end

  def recommended_funders
    Funder.joins(:recommendations).where("recipient_id = ? AND score >= ?", self.id, RECOMMENDATION_THRESHOLD).order("recommendations.score DESC, name ASC")
  end

  def recommended_funder?(funder)
    recommended_funders.pluck(:funder_id).take(RECOMMENDATION_LIMIT).include?(funder.id)
  end

  def similar_funders(funder)
    array = Funder.joins(:recommendations).where("recipient_id = ?", self.id).order("recommendations.score DESC, name ASC").to_a

    array[(array.index(funder)+1)..(array.index(funder)+7)].sample(3)
  end

end
