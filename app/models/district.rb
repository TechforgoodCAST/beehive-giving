class District < ApplicationRecord
  belongs_to :country

  has_many :funds, through: :geo_areas
  has_many :funders, -> { distinct }, through: :funds

  has_many :recipients

  has_and_belongs_to_many :geo_areas
  has_and_belongs_to_many :proposals

  validates :country, :name, presence: true
  validates :name, uniqueness: { scope: :country }
end
