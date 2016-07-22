class Restriction < ActiveRecord::Base

  has_many :eligibilities
  has_many :recipients, through: :eligibilities
  has_many :funders, through: :funding_streams # TODO: refactor
  has_and_belongs_to_many :funding_streams # TODO: refactor
  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds # TODO: refactor

  validates :details, presence: true, uniqueness: true

end
