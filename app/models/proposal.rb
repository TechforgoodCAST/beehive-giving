class Proposal < ApplicationRecord
  before_validation :clear_districts_if_country_wide
  after_save :initial_recommendation

  belongs_to :recipient

  has_many :answers, as: :category, dependent: :destroy
  accepts_nested_attributes_for :answers

  has_many :assessments
  has_many :enquiries, dependent: :destroy
  has_many :proposal_themes, dependent: :destroy
  has_many :themes, through: :proposal_themes

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  has_and_belongs_to_many :age_groups # TODO: deprecated
  has_and_belongs_to_many :beneficiaries # TODO: deprecated
  has_and_belongs_to_many :implementations # TODO: deprecated

  AFFECT_GEO = [
    ['One or more local areas', 0],
    ['One or more regions', 1],
    ['An entire country', 2],
    ['Across many countries', 3]
  ].freeze

  validates :affect_geo, inclusion: {
    in: 0..3, message: 'please select an option'
  }

  validates :all_funding_required, :private, inclusion: {
    message: 'please select an option', in: [true, false]
  }

  validates :countries, :recipient, :themes, presence: true

  validates :districts, presence: true, if: proc {
    affect_geo.present? && affect_geo < 2
  }

  validates :funding_duration, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 120
  }

  validates :funding_type, inclusion: {
    in: FUNDING_TYPES.pluck(1), message: 'please select an option'
  }

  validates :tagline, :title, presence: true, length: {
    maximum: 280, message: 'please use 280 characters or less'
  }

  validates :title, uniqueness: {
    scope: :recipient_id,
    message: 'each proposal must have a unique title'
  }

  validates :total_costs, numericality: {
    greater_than_or_equal_to: 0,
    message: 'please enter the amount of funding you are seeking'
  }

  validate :recipient_subscribed, on: :create

  include Workflow
  workflow_column :state
  workflow do
    state :basics do
      event :complete, transitions_to: :complete
    end
    state :invalid do
      event :complete, transitions_to: :complete
    end
    state :incomplete do
      event :complete, transitions_to: :complete
    end
    state :complete do
      event :complete, transitions_to: :complete
    end
  end

  def recipient_subscribed
    return if recipient.subscribed? || recipient.proposals.count.zero?
    errors.add(:title, 'Upgrade subscription to create multiple proposals')
  end

  def beehive_insight_durations # TODO: depreceted
    @beehive_insight_durations ||= call_beehive_insight(
      ENV['BEEHIVE_INSIGHT_DURATIONS_ENDPOINT'],
      duration: funding_duration
    )
  end

  def initial_recommendation # TODO: deprecated
    suitability = CheckSuitabilityFactory.new
    update_column(
      :suitability, suitability.call_each_with_total(self, Fund.active)
    )
  end

  def update_legacy_suitability # TODO: depreceted
    initial_recommendation unless
      suitability.key?(Fund.active.order(:updated_at).last&.slug)
  end

  def suitable_funds # TODO: depreceted
    suitability.sort_by { |fund| fund[1]['total'] }.reverse
  end

  def eligible_noquiz # TODO: depreceted
    # Same as eligible_funds except doesn't check for the quiz
    eligibility.select { |f, fund| fund.all_values_for('eligible').exclude?(false) }
  end

  def eligible_funds # TODO: deprecated
    eligibility.select { |f, _| eligible_status(f) == 1 }
  end

  def ineligible_funds # TODO: deprecated
    eligibility.select { |f, _| eligible_status(f).zero? }
  end

  def to_check_funds # TODO: deprecated
    eligibility.select { |f, _| eligible_status(f) == -1 }
  end

  def eligible?(fund_slug) # TODO: depreceted
    return nil unless eligibility[fund_slug]
    eligibility[fund_slug].dig('quiz', 'eligible') &&
      eligibility[fund_slug].all_values_for('eligible').exclude?(false)
  end

  def eligible_status(fund_slug) # TODO: deprecated
    return 0 unless eligibility[fund_slug].all_values_for('eligible').exclude?(false)
    return -1 unless eligibility[fund_slug]&.key?('quiz') # check
    eligible?(fund_slug) ? 1 : 0 # eligible : ineligible
  end

  def eligibility_as_text(fund_slug) # TODO: deprecated
    {
      -1 => 'Check', 0 => 'Ineligible', 1 => 'Eligible'
    }[eligible_status(fund_slug)]
  end

  def ineligible_reasons(fund_slug) # TODO: depreceted
    return [] if eligible?(fund_slug)
    eligibility[fund_slug].select { |_r, e| e['eligible'] == false }.keys
  end

  def ineligible_fund_ids # TODO: depreceted
    Fund.where(slug: ineligible_funds.keys).pluck(:id)
  end

  def suitable?(fund_slug, scale = 1) # TODO: depreceted
    score = suitability[fund_slug]&.dig('total')
    return -1 if score.nil?
    scale = score > 1 ? score.ceil : 1
    [
      [0.2, 0], # unsuitable
      [0.5, 1], # fair suitability
      [1.0, 2], # suitable
    ].each do |v|
      return v[1] if score <= (v[0] * scale)
    end
  end

  def suitable_status(fund_slug) # TODO: depreceted
    suitable?(fund_slug)
  end

  private

    def clear_districts_if_country_wide
      return if affect_geo.nil?
      self.districts = [] if affect_geo > 1
    end

    def call_beehive_insight(endpoint, data) # TODO: depreceted
      options = {
        body: { data: data }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN']
        }
      }
      resp = HTTParty.post(endpoint, options)
      JSON.parse(resp.body).to_h
    end
end
