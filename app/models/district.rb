class District < ActiveRecord::Base

  belongs_to :country

  serialize :geometry

  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :grants
  has_and_belongs_to_many :funder_attributes
  has_and_belongs_to_many :enquiries

  validates :country, :label, :district, presence: true

end
