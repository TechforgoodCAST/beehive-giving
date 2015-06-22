class Recommendation < ActiveRecord::Base

  RECOMMENDATION_QUALITY = ["Good suggestion", "Neutral suggestion", "Poor suggestion"]

  belongs_to :funder
  belongs_to :recipient

  validates :funder, :recipient, :score, presence: true
  validates_uniqueness_of :funder_id, scope: :recipient_id, :message => 'only one per funder and recipient'

  validates :recommendation_quality, presence: true,
            if: Proc.new { |recommendation| recommendation.recipient.recommended_funder?(recommendation.funder) if recommendation.recipient }
  validates :recommendation_quality, :inclusion => { in: RECOMMENDATION_QUALITY },
            if: Proc.new { |recommendation| recommendation.recipient.recommended_funder?(recommendation.funder) if recommendation.recipient}

end
