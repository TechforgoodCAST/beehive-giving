class AgeGroup < ActiveRecord::Base
  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :proposals
end
