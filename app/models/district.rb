class District < ActiveRecord::Base
  belongs_to :country
  has_and_belongs_to_many :organisations
end
