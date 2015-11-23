class Recommendation < ActiveRecord::Base

  RECOMMENDATION_QUALITY = ["Good suggestion", "Neutral suggestion", "Poor suggestion"]

  belongs_to :funder
  belongs_to :recipient

  validates :funder, :recipient, :score, presence: true
  validates_uniqueness_of :funder_id, scope: :recipient_id, :message => 'only one per funder and recipient'
  validates :eligibility, inclusion: {in: ['Eligible', 'Ineligible']}

end
