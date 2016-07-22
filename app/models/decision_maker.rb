class DecisionMaker < ActiveRecord::Base

  has_and_belongs_to_many :funds
  has_many :funders, -> { distinct }, through: :funds
  
  validates :name, presence: true, uniqueness: true

end
