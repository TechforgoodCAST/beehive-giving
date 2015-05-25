class FundingStream < ActiveRecord::Base

  has_and_belongs_to_many :funders
  has_and_belongs_to_many :restrictions

  validates :label, :funders, :restrictions, presence: true

end
