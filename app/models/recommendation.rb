class Recommendation < ApplicationRecord
  RECOMMENDATION_QUALITY = ['Good suggestion', 'Neutral suggestion',
                            'Poor suggestion'].freeze

  belongs_to :proposal
  belongs_to :fund

  validates :proposal, :fund, :fund_slug, :score, presence: true
  validates :fund, :fund_slug, uniqueness: { scope: :proposal }
  # TODO: validates :eligibility, inclusion: {in: ['Eligible', 'Ineligible']}

  before_validation :set_fund_slug, unless: :fund_slug
  before_save :calculate_total_recommendation

  private

    def set_fund_slug
      self.fund_slug = fund.slug
    end

    def calculate_total_recommendation
      return unless grant_amount_recommendation && grant_duration_recommendation
      self.total_recommendation = score + grant_amount_recommendation +
                                  grant_duration_recommendation
    end
end
