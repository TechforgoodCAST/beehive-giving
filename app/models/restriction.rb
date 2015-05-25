class Restriction < ActiveRecord::Base
  has_and_belongs_to_many :funding_streams
  has_many :eligibilities
  has_many :recipients, :through => :eligibilities
  has_many :funders, :through => :funding_streams

  validates :details, presence: true
end
