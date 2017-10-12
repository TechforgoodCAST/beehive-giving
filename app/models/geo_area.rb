class GeoArea < ApplicationRecord
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :countries

  has_many :funds

  validates :name, presence: true, uniqueness: true
  validates :countries, presence: true

  def short_name
    self[:short_name].present? ? self[:short_name] : self[:name]
  end
end
