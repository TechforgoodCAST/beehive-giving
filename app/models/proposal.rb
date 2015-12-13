class Proposal < ActiveRecord::Base

  before_save :total_costs, :build_proposal_recommendation

  belongs_to :recipient
  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  validates :title, uniqueness: { scope: :recipient, message: 'cannot have two proposals with the same name' }

  validates :recipient, :title, :tagline, :gender, :min_age,
            :max_age, :beneficiaries_count, :countries, :districts,
            :funding_duration, :activity_costs, :people_costs, :capital_costs,
            :other_costs, :total_costs, :all_funding_required, :outcome1,
            presence: true

  validates :beneficiaries, presence: true, unless: 'self.beneficiaries_other.present?'
  validates :beneficiaries_other, presence: { message: "must uncheck 'Other' or specify details" },
            if: :beneficiaries_other_required

  validates :title, :tagline, length: { maximum: 140 }

  validates :gender, inclusion: { in: Profile::GENDERS, message: 'please select an option' }

  validates :funding_duration, :beneficiaries_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :activity_costs, :people_costs, :capital_costs,
            :other_costs, :total_costs, numericality: { greater_than_or_equal_to: 0 },
            format: { with: /\A\d+\.?\d{0,2}\z/, message: 'only two decimal places allowed' }

  validates :activity_costs_estimated, :people_costs_estimated, :capital_costs_estimated,
            :other_costs_estimated, inclusion: { message: 'please select an option', in: [true, false] }

  def total_costs
    self.total_costs = self.activity_costs + self.people_costs + self.capital_costs + self.other_costs if self.activity_costs && self.people_costs && self.capital_costs && self.other_costs
  end

  def build_proposal_recommendation
    Funder.active.each do |funder|
      recommendation = load_recommendation(funder)
      recommendation.update_attribute(:grant_amount_recommendation, calculate_grant_amount_recommendation(funder))
      recommendation.update_attribute(:grant_duration_recommendation, calculate_grant_duration_recommendation(funder))
    end
  end

  private

  def load_recommendation(funder)
    Recommendation.where(recipient: recipient, funder: funder).first
  end

  def proposal_recommendation(funder, group, request, precision)
    score = 0
    total_grants = funder.recent_grants.count
    funder.recent_grants.group(group).count.each do |k, v|
      score += (v.to_f / total_grants) if (k-precision..k+precision).include?(request)
    end
    score
  end

  def calculate_grant_amount_recommendation(funder)
    proposal_recommendation(funder, 'amount_awarded', total_costs, 5000)
  end

  def calculate_grant_duration_recommendation(funder)
    if funder.recent_grants.where('days_from_start_to_end is NULL').count == 0
      proposal_recommendation(funder, 'days_from_start_to_end', (funding_duration * 30), 28)
    else
      0
    end
  end

end
