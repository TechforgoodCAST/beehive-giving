class Recommendation < ActiveRecord::Base

  before_save :calculate_total_recommendation

  RECOMMENDATION_QUALITY = ["Good suggestion", "Neutral suggestion", "Poor suggestion"]

  belongs_to :proposal
  belongs_to :fund
  belongs_to :funder
  belongs_to :recipient

  validates :funder, :recipient, :score, presence: true
  validates_uniqueness_of :funder_id, scope: :recipient_id, :message => 'only one per funder and recipient'
  # refactor
  # validates :eligibility, inclusion: {in: ['Eligible', 'Ineligible']}

  def calculate_total_recommendation
    self.total_recommendation = self.score + self.grant_amount_recommendation + self.grant_duration_recommendation if self.grant_amount_recommendation && self.grant_duration_recommendation
  end

end
