class ApplicationProcess < ActiveRecord::Base
  has_and_belongs_to_many :funder_attributes
end