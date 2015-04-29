class Country < ActiveRecord::Base
  has_many :districts
  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :funder_attributes

  validates :name, :alpha2, presence: true
end
