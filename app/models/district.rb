class District < ApplicationRecord
  belongs_to :country

  has_and_belongs_to_many :proposals

  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds

  validates :country, :name, presence: true
  validates :name, uniqueness: { scope: :country }
end
