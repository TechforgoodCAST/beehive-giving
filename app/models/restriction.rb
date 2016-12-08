class Restriction < ActiveRecord::Base
  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds
  has_many :eligibilities
  has_many :recipients, through: :eligibilities

  # TODO: has_many :proposal_eligibilities
  # TODO: has_many :proposals, through: :proposal_eligibilities

  validates :details, presence: true, uniqueness: true
end
