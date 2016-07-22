class FundingType < ActiveRecord::Base

  FUNDING_TYPE = [
    'Capital funding',
    'Revenue funding - project costs',
    'Revenue funding - running costs',
    'Revenue funding - unrestricted (both project and running costs)',
    'Other'
  ]

  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds
  has_and_belongs_to_many :funder_attributes

  validates :label, presence: true, inclusion: { in: FUNDING_TYPE }, uniqueness: true

end
