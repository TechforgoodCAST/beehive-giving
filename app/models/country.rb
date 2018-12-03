class Country < ApplicationRecord
  has_many :districts
  has_many :funds, through: :geo_areas
  has_many :funders, -> { distinct }, through: :funds

  has_many :recipients

  has_and_belongs_to_many :geo_areas
  has_and_belongs_to_many :proposals

  validates :name, :alpha2, presence: true, uniqueness: true
end
