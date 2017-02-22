class Funder < Organisation
  scope :active, -> { where(active_on_beehive: true) }

  CLOSED_FUNDERS = ['Cripplegate Foundation', 'The Baring Foundation'].freeze

  has_many :funds
  has_many :grants
  has_many :districts, -> { distinct }, through: :grants
  has_many :countries, -> { distinct }, through: :grants
  has_many :countries_by_year, ->(object) { where('grants.approved_on <= ? AND grants.approved_on >= ?', "#{object.current_attribute.year}-12-31", "#{object.current_attribute.year}-01-01") }, through: :grants, source: :countries
  has_many :districts_by_year, ->(object) { where('grants.approved_on <= ? AND grants.approved_on >= ?', "#{object.current_attribute.year}-12-31", "#{object.current_attribute.year}-01-01") }, through: :grants, source: :districts

  has_many :recipients, through: :grants
  has_many :recent_recipients, ->(object) { where('grants.approved_on <= ? AND grants.approved_on >= ?', "#{object.current_attribute.year}-12-31", "#{object.current_attribute.year}-01-01") }, through: :grants, source: :recipient

  has_many :age_groups, through: :funder_attributes

  has_many :funder_attributes, dependent: :destroy
  has_many :approval_months, through: :funder_attributes
  has_many :beneficiaries, through: :funder_attributes

  has_many :recipients, through: :grants
  has_many :profiles, through: :recipients, dependent: :destroy

  has_and_belongs_to_many :funding_streams # TODO: remove once data migrated
  has_many :restrictions, through: :funds
  has_many :recommendations

  alias attributes funder_attributes # TODO: deprecated

  def load_map_all_data
    features = []
    grant_count = Grant.recent(2014).joins(:districts).group('districts.name').count

    Grant.recent(2014).joins(:districts).group('districts.name').sum(:amount_awarded).each do |k, v|
      district = District.find_by(district: k)

      features << {
        type: 'Feature', properties: {
          name: k,
          slug: k.downcase.gsub(/[^a-z0-9]+/, '-'),
          amount_awarded: v,
          amount_awarded_hue: get_hue(v, 9_304_589),
          grant_count: grant_count[k],
          grant_count_hue: get_hue(grant_count[k], 301),
          rank: district.indices_rank,
          rank_hue: get_hue((district.indices_rank_proportion_most_deprived_ten_percent.to_f * 100).round(0), 49),
          rank_proportion: (district.indices_rank_proportion_most_deprived_ten_percent.to_f * 100).round(0)
        }, geometry: district.geometry
      }
    end

    { type: 'FeatureCollection', features: features }.to_json
  end

  def load_map_data
    return unless districts.any?
    features = []
    amount_awarded_max = districts_by_year.group(:name).sum(:amount_awarded).sort_by { |_, v| v }.reverse.to_h.values.first
    grant_count = districts_by_year.group(:name).count
    grant_count_max = districts_by_year.group(:name).count.sort_by { |_, v| v }.reverse.to_h.values.first
    grant_average = districts_by_year.group(:name).average(:amount_awarded)

    districts_by_year.group(:name).sum(:amount_awarded).each do |k, v|
      district = District.find_by(district: k)

      features << {
        type: 'Feature', properties: {
          name: k,
          slug: k.downcase.gsub(/[^a-z0-9]+/, '-'),
          amount_awarded: v,
          amount_awarded_hue: get_hue(v, amount_awarded_max),
          grant_count: grant_count[k],
          grant_count_hue: get_hue(grant_count[k], grant_count_max),
          grant_average: grant_average[k],
          rank: district.indices_rank,
          rank_hue: get_hue((district.indices_rank_proportion_most_deprived_ten_percent.to_f * 100).round(0), 49),
          rank_proportion: (district.indices_rank_proportion_most_deprived_ten_percent.to_f * 100).round(0)
        }, geometry: district.geometry
      }
    end

    { type: 'FeatureCollection', features: features }.to_json
  end

  def save_map_data
    current_attribute.update_column(:map_data, get_map_data)
  end

  def update_current_attribute
    current_attribute.update_column(:no_of_recipients_funded, recent_grants(current_attribute.year).distinct.pluck(:recipient_id).count)
    current_attribute.set_shared_recipient_ids
  end

  def get_hue(amount, max, segments = 10)
    segment = max.to_f / segments
    segments.times do |i|
      return i if amount > segment * i && amount <= segment * (i + 1)
    end
  end

  def current_attribute # TODO: deprecated
    attributes.where(funding_stream: 'All').order(year: :desc).first
  end

  def recent_grants(year = Time.zone.today.year) # TODO: deprecated
    grants.where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01")
  end

  def shared_recipient_ids # TODO: deprecated
    recent_grants_recipient_ids = recent_grants(current_attribute.year).pluck(:recipient_id).uniq
    result = {}
    Funder.active.each do |funder|
      unless funder == self
        result[funder.id] = recent_grants_recipient_ids & funder.recent_grants(current_attribute.year).pluck(:recipient_id).uniq
      end
    end
    result.delete_if { |_, v| v == [] }
    result.sort_by { |_, v| v.count }.reverse.to_h
  end

  def multiple_funding_from_funder # TODO: deprecated
    recent_grants(current_attribute.year).group(:recipient_id).having('count(*) > 1').count
  end

  def no_of_grants_per_recipient # TODO: deprecated
    result = {}
    recent_grants(current_attribute.year).group(:recipient_id).count.each do |_, v|
      result[v] = result[v] || 0
      result[v] += 1
    end
    result = result.sort_by { |k, _| k }.to_h
  end

  def recommended_recipients # TODO: deprecated
    Recipient.includes(:recommendations, :proposals, :enquiries)
             .where("recommendations.funder_id = ? AND
              recommendations.score >= ? AND
              recommendations.eligibility = ? AND
              enquiries.funder_id = ?",
                    id,
                    Recipient::RECOMMENDATION_THRESHOLD,
                    'Eligible',
                    id)
             .distinct
             .order('proposals.created_at DESC, recommendations.eligibility ASC, recommendations.score DESC')
             .order(:name)
  end
end
