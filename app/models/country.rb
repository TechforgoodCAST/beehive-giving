class Country < ActiveRecord::Base

  has_many :districts

  has_and_belongs_to_many :profiles # TODO: refactor
  has_and_belongs_to_many :proposals
  has_and_belongs_to_many :grants
  has_and_belongs_to_many :funder_attributes # TODO: refactor
  has_and_belongs_to_many :enquiries # TODO: refactor

  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds

  validates :name, :alpha2, presence: true, uniqueness: true

end
