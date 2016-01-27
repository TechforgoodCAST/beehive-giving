class District < ActiveRecord::Base

  belongs_to :country

  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :proposals
  has_and_belongs_to_many :grants
  has_and_belongs_to_many :funder_attributes
  has_and_belongs_to_many :enquiries

  serialize :geometry

  validates :country, :label, :district, presence: true

  def recent_grants(year=2015)
    self.grants.where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01")
  end

end
