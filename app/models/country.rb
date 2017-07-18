class Country < ApplicationRecord
  has_many :districts

  has_and_belongs_to_many :proposals
  has_and_belongs_to_many :profiles # TODO: deprecated

  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds

  validates :name, :alpha2, presence: true, uniqueness: true
end
