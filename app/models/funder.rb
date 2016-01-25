class Funder < Organisation

  has_many :grants
  has_many :districts, :through => :grants
  has_many :countries, :through => :grants
  has_many :countries_by_year, -> (object) { where('grants.approved_on <= ? AND grants.approved_on >= ?', "#{object.current_attribute.year}-12-31", "#{object.current_attribute.year}-01-01") }, :through => :grants, :source => :countries
  has_many :districts_by_year, -> (object) { where('grants.approved_on <= ? AND grants.approved_on >= ?', "#{object.current_attribute.year}-12-31", "#{object.current_attribute.year}-01-01") }, :through => :grants, :source => :districts

  has_many :features
  has_many :enquiries

  has_many :funder_attributes, dependent: :destroy
  has_many :approval_months, :through => :funder_attributes
  has_many :beneficiaries, :through => :funder_attributes

  has_many :recipients, :through => :grants
  has_many :profiles, :through => :recipients, dependent: :destroy

  has_and_belongs_to_many :funding_streams
  has_many :restrictions, :through => :funding_streams

  alias_method :attributes, :funder_attributes

  has_many :recommendations

  scope :active, -> {where(active_on_beehive: true)}

  CLOSED_FUNDERS = ['Cripplegate Foundation']

  def get_map_data
    if self.districts.any?
      features = []
      amount_awarded_max = self.districts_by_year.group(:district).sum(:amount_awarded).sort_by {|k, v| v}.reverse.to_h.values.first
      grant_count = self.districts_by_year.group(:district).count
      grant_count_max = self.districts_by_year.group(:district).count.sort_by {|k, v| v}.reverse.to_h.values.first
      grant_average = self.districts_by_year.group(:district).average(:amount_awarded)

      self.districts_by_year.group(:district).sum(:amount_awarded).each do |k, v|
        features << {
          type: "Feature", properties: {
            name: k,
            slug: k.downcase.gsub(/[^a-z0-9]+/, '-'),
            amount_awarded: v,
            amount_awarded_hue: self.get_hue(v, amount_awarded_max),
            grant_count: grant_count[k],
            grant_count_hue: self.get_hue(grant_count[k], grant_count_max),
            grant_average: grant_average[k]
          }, geometry: District.find_by_district(k).geometry
        }
      end

      return { type: "FeatureCollection", features: features }.to_json
    end
  end

  def save_map_data
    self.current_attribute.update_column(:map_data, self.get_map_data)
  end

  def get_hue(amount, max, segments=7)
    segment = max.to_f / segments
    segments.times do |i|
      return i+1 if amount > segment * i && amount <= segment * (i+1)
    end
  end

  def eligible_organisations
    array = []
    Recipient.joins(:eligibilities).order(:id).uniq.each do |recipient|
      array << recipient if recipient.eligible?(self)
    end
    array
  end

  def current_attribute
    # self.attributes.where('funding_stream = ? AND grant_count > ?', 'All', 0).order(year: :desc).first
    self.attributes.where(funding_stream: 'All').order(year: :desc).first
  end

  def recent_grants
    self.grants.where('approved_on <= ? AND approved_on >= ?', "#{self.current_attribute.year}-12-31", "#{self.current_attribute.year}-01-01")
  end

  def recommended_recipients
    Recipient.joins(:recommendations)
      .where("recommendations.funder_id = ? AND
              recommendations.total_recommendation >= ? AND
              recommendations.eligibility = ?",
              self.id,
              Recipient::RECOMMENDATION_THRESHOLD,
              'Eligible')
      .order("recommendations.eligibility ASC, recommendations.total_recommendation DESC, name ASC")
  end

end
