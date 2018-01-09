class Proposal < ApplicationRecord
  before_validation :clear_districts_if_country_wide
  before_save :save_all_age_groups_if_all_ages,
              :clear_age_groups_and_gender_unless_affect_people
  after_save :initial_recommendation

  belongs_to :recipient

  has_many :answers, as: :category, dependent: :destroy
  accepts_nested_attributes_for :answers

  has_many :assessments
  has_many :enquiries, dependent: :destroy
  has_many :proposal_themes, dependent: :destroy
  has_many :themes, through: :proposal_themes

  has_and_belongs_to_many :beneficiaries # TODO: deprecated
  has_and_belongs_to_many :age_groups
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :implementations

  TYPE_OF_SUPPORT = ['Only financial', 'Mostly financial',
                     'Equal financial and non-financial',
                     'Mostly non-financial', 'Only non-financial'].freeze
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other'].freeze
  AFFECT_GEO = [
    ['One or more local areas', 0],
    ['One or more regions', 1],
    ['An entire country', 2],
    ['Across many countries', 3]
  ].freeze

  include Workflow
  workflow_column :state
  workflow do
    state :basics do
      event :next_step, transitions_to: :initial
    end
    state :initial do
      event :next_step, transitions_to: :registered
    end
    state :transferred do
      event :next_step, transitions_to: :registered
    end
    state :registered do
      event :next_step, transitions_to: :complete
    end
    state :complete do
      event :next_step, transitions_to: :complete
    end
  end

  validate :prevent_second_proposal_until_first_is_complete,
           if: :initial?, on: :create

  # Requirements
  validates :recipient, :funding_duration, :themes, presence: true
  validates :type_of_support, inclusion: { in: TYPE_OF_SUPPORT,
                                           message: 'please select an option' }
  validates :funding_type, inclusion: { in: FUNDING_TYPES.pluck(1),
                                        message: 'please select an option' }
  validates :funding_duration,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :total_costs, numericality: {
    greater_than_or_equal_to: 0,
    message: 'please enter the amount of funding you are seeking'
  }
  validates :total_costs_estimated,
            inclusion: { message: 'please select an option', in: [true, false] }
  validates :all_funding_required,
            inclusion: { message: 'please select an option', in: [true, false] }

  # Beneficiaries
  validates :affect_people,
            inclusion: { in: [true, false], message: 'please select an option' }
  validates :gender, :age_groups,
            presence: { message: 'Please select an option' },
            if: :affect_people?
  validates :gender,
            inclusion: { in: GENDERS, message: 'please select an option' },
            if: :affect_people?
  # TODO: ensure fields cleared unless :affect_people?

  # Location
  validates :affect_geo, inclusion: { in: 0..3,
                                      message: 'please select an option' }
  validates :countries, presence: true
  validates :districts,
            presence: true,
            if: proc { affect_geo.present? && affect_geo < 2 }

  # Privacy
  validates :private, inclusion: { in: [true, false],
                                   message: 'please select an option' }

  # Registered
  validates :title, uniqueness: {
    scope: :recipient_id,
    message: 'each proposal must have a unique title'
  }, if: proc { registered? || complete? }
  validates :title, :tagline, :outcome1, presence: true, length: {
    maximum: 280, message: 'please use 280 characters or less'
  }, if: proc { registered? || complete? }
  validates :implementations, presence: true,
                              unless: :implementations_other_required,
                              if: proc { registered? || complete? }
  validates :implementations_other,
            presence: { message: "please uncheck 'Other' or specify details" },
            if: :implementations_other_required

  validate :recipient_subscribed, on: :create

  def self.order_by(col)
    case col
    when 'name'
      order :title
    when 'amount'
      order total_costs: :desc
    else
      order created_at: :desc
    end
  end

  def recipient_subscribed
    return if recipient.subscribed? || recipient.proposals.count.zero?
    errors.add(:title, 'Upgrade subscription to create multiple proposals')
  end

  def beehive_insight_durations
    @beehive_insight_durations ||= call_beehive_insight(
      ENV['BEEHIVE_INSIGHT_DURATIONS_ENDPOINT'],
      duration: funding_duration
    )
  end

  def initial_recommendation
    # TODO: implement
    # eligibility = CheckEligibilityFactory.new
    # eligibility_stubs = CheckEligibilityFactory.stubs
    # suitability = CheckSuitabilityFactory.new

    # Assessment.import(eligibility.call_each(Fund.active, self))

    # eligibility.update(Fund.active)
    # eligibility.update(proposal)

    # update_columns(
    #   eligibility: eligibility_stubs.call_each(self, Fund.stubs),
    #   suitability: suitability.call_each_with_total(self, Fund.active)
    # )
  end

  def update_legacy_suitability
    # TODO: refactor
    initial_recommendation unless
      suitability.key?(Fund.active.order(:updated_at).last&.slug)
  end

  def suitable_funds
    suitability.sort_by { |fund| fund[1]['total'] }.reverse
  end

  def eligible_noquiz
    # Same as eligible_funds except doesn't check for the quiz
    eligibility.select { |f, fund| fund.all_values_for('eligible').exclude?(false) }
  end

  def eligible_funds
    eligibility.select { |f, _| eligible_status(f) == 1 }
  end

  def ineligible_funds
    eligibility.select { |f, _| eligible_status(f).zero? }
  end

  def to_check_funds
    eligibility.select { |f, _| eligible_status(f) == -1 }
  end

  def eligible?(fund_slug)
    return nil unless eligibility[fund_slug]
    eligibility[fund_slug].dig('quiz', 'eligible') &&
      eligibility[fund_slug].all_values_for('eligible').exclude?(false)
  end

  def eligible_status(fund_slug)
    return 0 unless eligibility[fund_slug].all_values_for('eligible').exclude?(false)
    return -1 unless eligibility[fund_slug]&.key?('quiz') # check
    eligible?(fund_slug) ? 1 : 0 # eligible : ineligible
  end

  def eligibility_as_text(fund_slug)
    {
      -1 => 'Check', 0 => 'Ineligible', 1 => 'Eligible'
    }[eligible_status(fund_slug)]
  end

  def ineligible_reasons(fund_slug)
    return [] if eligible?(fund_slug)
    eligibility[fund_slug].select { |_r, e| e['eligible'] == false }.keys
  end

  def ineligible_fund_ids # TODO: refactor
    Fund.where(slug: ineligible_funds.keys).pluck(:id)
  end

  def suitable?(fund_slug, scale = 1)
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

  def suitable_status(fund_slug)
    suitable?(fund_slug)
  end

  private

    def save_all_age_groups_if_all_ages
      return unless age_group_ids.include?(AgeGroup.first.id)
      self.age_group_ids = AgeGroup.pluck(:id)
    end

    def prevent_second_proposal_until_first_is_complete
      return unless recipient.proposals.count == 1 &&
                    recipient.proposals.where(state: 'complete').count < 1
      errors.add(
        :proposal,
        'Please complete your first proposal before creating a second.'
      )
    end

    def clear_districts_if_country_wide
      return if affect_geo.nil?
      self.districts = [] if affect_geo > 1
    end

    def clear_age_groups_and_gender_unless_affect_people
      return if affect_people?
      self.age_groups = []
      self.gender = nil
    end

    def call_beehive_insight(endpoint, data)
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
