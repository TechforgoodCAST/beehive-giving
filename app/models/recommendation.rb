class Recommendation < ActiveRecord::Base

  RECOMMENDATION_QUALITY = ['Good suggestion', 'Neutral suggestion', 'Poor suggestion']

  belongs_to :proposal
  belongs_to :fund

  validates :proposal, :fund, :fund_slug, presence: true
  validates :fund, :fund_slug, uniqueness: { scope: :proposal }

  before_validation :set_fund_slug, unless: :fund_slug
  before_save :calculate_total_recommendation

  # belongs_to :funder
  # belongs_to :recipient
  # validates :funder, :recipient, :score, presence: true
  # validates_uniqueness_of :funder_id, scope: :recipient_id, :message => 'only one per funder and recipient'
  # refactor
  # validates :eligibility, inclusion: {in: ['Eligible', 'Ineligible']}

  private

    def set_fund_slug
      self.fund_slug = self.fund.slug
    end

    def calculate_total_recommendation
      self.total_recommendation = self.score + self.grant_amount_recommendation + self.grant_duration_recommendation if self.grant_amount_recommendation && self.grant_duration_recommendation
    end

end
