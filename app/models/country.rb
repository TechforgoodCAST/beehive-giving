class Country < ApplicationRecord
  has_many :districts

  has_and_belongs_to_many :proposals

  has_and_belongs_to_many :geo_areas

  has_many :funds, through: :geo_areas
  has_many :funders, -> { distinct }, through: :funds

  validates :name, :alpha2, presence: true, uniqueness: true
end
