class District < ActiveRecord::Base

  belongs_to :country

  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :proposals
  has_and_belongs_to_many :grants
  has_and_belongs_to_many :funder_attributes
  has_and_belongs_to_many :enquiries

  serialize :geometry

  validates :country, :label, :district, presence: true

  def recent_grants(year=Date.today.year)
    self.grants.where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01")
  end

  def ids_by_grant_count(org_type, year=Date.today.year)
    self.recent_grants(year).group("#{org_type}_id").count.sort_by {|k, v| v}.reverse.to_h
  end

  def ids_by_grant_sum(org_type, year=Date.today.year)
    self.recent_grants(year).group("#{org_type}_id").sum(:amount_awarded).sort_by {|k, v| v}.reverse.to_h
  end

end
