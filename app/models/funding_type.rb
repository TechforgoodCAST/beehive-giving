class FundingType < ActiveRecord::Base
  has_and_belongs_to_many :funder_attributes
  validates :label, presence: true
end
