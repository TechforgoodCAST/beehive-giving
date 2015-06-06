class Country < ActiveRecord::Base

  has_many :districts

  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :grants
  has_and_belongs_to_many :funder_attributes
  has_and_belongs_to_many :enquiries

  validates :name, :alpha2, presence: true

end
