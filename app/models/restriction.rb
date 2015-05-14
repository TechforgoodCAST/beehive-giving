class Restriction < ActiveRecord::Base
  has_and_belongs_to_many :funders
  has_many :eligibilities
  has_many :recipients, :through => :eligibilities

  validates :funders, :details, :funding_stream, presence: true
end
