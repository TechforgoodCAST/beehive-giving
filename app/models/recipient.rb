class Recipient < Organisation

  has_many :grants
  has_many :features, dependent: :destroy
  has_many :enquiries
  has_many :eligibilities
  has_many :restrictions, :through => :eligibilities
  accepts_nested_attributes_for :eligibilities

  has_one :recipient_attribute
  alias_method :attribute, :recipient_attribute

  has_many :recommendations, dependent: :destroy
  has_many :countries, :through => :profiles
  has_many :districts, :through => :profiles
  has_many :beneficiaries, :through => :profiles

  PROFILE_MAX_FREE_LIMIT = 4

  def recipient_profile_limit
    if (Date.today.year - self.founded_on.year) < 4
      (Date.today.year - self.founded_on.year) + 1
    else
      4
    end
  end

  def can_unlock_funder?(funder)
    profiles.count <= PROFILE_MAX_FREE_LIMIT && profiles.count > unlocked_funders.size
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
    profiles.count <= Date.today.year - self.founded_on.year unless profiles.count == 4
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
    recommendation = Recommendation.find_or_initialize_by(
      recipient: self,
      funder: funder
    )
    recommendation.update_attributes(
      score: recommendation.score + score
    )
    recommendation.save
  end

  def initial_recommendation
    recommendations.destroy_all
    Funder.all.each do |funder|
      score = 0
      if funder.attributes.any?
        funder.attributes.where('funding_stream = ?', 'All').first.countries.where(alpha2: country).uniq.each { |f| score += 0.1 }
      end
      build_recommendation(funder, score)
    end
  end

  def refined_recommendation
    recommendations.destroy_all
    Funder.all.each do |funder|
      score = 0

      if funder.attributes.any?
        # Location
        countries.map(&:alpha2).each do |country|
          score += 0.1 if funder.attributes.where('funding_stream = ?', 'All').first.countries.pluck(:alpha2).uniq.include?(country)
        end

        districts.map(&:district).each do |district|
          score += 0.1 if funder.attributes.where('funding_stream = ?', 'All').first.districts.pluck(:district).uniq.include?(district)
        end

        # Beneficiaries
        beneficiaries.map(&:label).each do |beneficiary|
          score += 0.1 if funder.attributes.where('funding_stream = ?', 'All').first.beneficiaries.pluck(:label).uniq.include?(beneficiary)
        end

        if funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_min_age
          score += 0.1 if profiles.first.min_age >= funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_min_age
        end

        if funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_max_age
          score += 0.1 if profiles.first.min_age <= funder.attributes.where('funding_stream = ?', 'All').first.beneficiary_max_age
        end

        # Age
        if funder.attributes.where('funding_stream = ?', 'All').first.funded_average_age
          score += 0.1 if (Date.today - founded_on) >= (funder.attributes.where('funding_stream = ?', 'All').first.funded_average_age - 2.5) && (Date.today - founded_on) <= (funder.attributes.where('funding_stream = ?', 'All').first.funded_average_age + 2.5)
        end

        # Finance
        if funder.attributes.where('funding_stream = ?', 'All').first.funded_average_income
          score += 0.1 if profiles.first.income >= (funder.attributes.where('funding_stream = ?', 'All').first.funded_average_income - 25000) && profiles.first.income <= (funder.attributes.where('funding_stream = ?', 'All').first.funded_average_income + 25000)
        end
      end

      build_recommendation(funder, score)
    end
  end

  def recommended_funder?(funder)
    Funder.joins(:recommendations).where("recipient_id = ? AND score > ?", self.id, 0).order("recommendations.score DESC").order("name ASC").pluck(:funder_id).include?(funder.id)
  end

end
