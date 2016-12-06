class District < ActiveRecord::Base

  belongs_to :country
  has_and_belongs_to_many :proposals
  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds

  has_and_belongs_to_many :profiles # TODO: deprecated
  has_and_belongs_to_many :grants # TODO: deprecated
  has_and_belongs_to_many :funder_attributes # TODO: deprecated

  serialize :geometry # TODO: deprecated

  validates :country, :label, :district, presence: true
  validates :district, uniqueness: { scope: :country } # TODO: rename 'district' to 'name'

  # TODO: deprecated
  def grant_count_in_region(year = Date.today.year, region = (self.region || sub_country))
    District.joins(:grants).where('region = ? OR sub_country = ?', region, region).where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01").group(:district).count.sort_by { |_,v| v }.reverse.to_h
  end

  # TODO: deprecated
  def amount_awarded_in_region(year = Date.today.year, region = (self.region || sub_country))
    District.joins(:grants).where('region = ? OR sub_country = ?', region, region).where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01").group(:district).sum(:amount_awarded).sort_by { |_,v| v }.reverse.to_h
  end

  # TODO: deprecated
  def rank_in_region(year = Date.today.year)
    data = []
    grant_count_in_region(year).each do |k, v|
      data << {
        district: k,
        grant_count: v,
        amount_awarded: amount_awarded_in_region(year)[k]
      }
    end
    data
  end

  # TODO: deprecated
  def recent_grants(year = Date.today.year)
    grants.where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01")
  end

  # TODO: deprecated
  def district_funder_ids(year = Date.today.year)
    recent_grants(year).pluck(:funder_id).uniq
  end

  # TODO: deprecated
  def ids_by_grant_count(org_type, year = Date.today.year)
    recent_grants(year).group("#{org_type}_id").count.sort_by { |_, v| v }.reverse.to_h
  end

  # TODO: deprecated
  def ids_by_grant_sum(org_type, year = Date.today.year)
    recent_grants(year).group("#{org_type}_id").sum(:amount_awarded).sort_by { |_, v| v }.reverse.to_h
  end

  # TODO: deprecated
  def create_hash(category, data)
    if data > 0 && data <= 40
      deprivation = 'Very poor'
      class_name = 'very-poor'
    elsif data > 40 && data <= 80
      deprivation = 'Poor'
      class_name = 'poor'
    elsif data > 80 && data <= 180
      deprivation = 'Fair'
      class_name = 'fair'
    elsif data > 180 && data <= 260
      deprivation = 'Good'
      class_name = 'good'
    elsif data > 260 && data <= 326
      deprivation = 'Excellent'
      class_name = 'excellent'
    end
    {
      category: category,
      rank: data,
      inverted_rank: (326 - data),
      deprivation: deprivation,
      class: class_name
    }
  end

  # TODO: deprecated
  def imd_chart_data
    [
      create_hash('Overall', indices_rank),
      create_hash('Income', indices_income_rank),
      create_hash('Employment', indices_employment_rank),
      create_hash('Education', indices_education_rank),
      create_hash('Health', indices_health_rank),
      create_hash('Crime', indices_crime_rank),
      create_hash('Barriers to housing and services', indices_barriers_rank),
      create_hash('Living environment', indices_living_rank)
    ]
  end

end
