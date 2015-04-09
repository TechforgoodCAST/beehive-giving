class Country < ActiveRecord::Base
  has_many :districts
  has_and_belongs_to_many :profiles

  validates :name, :alpha2, presence: true
end
