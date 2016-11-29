class Outcome < ActiveRecord::Base

  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds

  validates :outcome, presence: true, uniqueness: true

end
