class Fund < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  scope :active, -> { where(state: 'active') }
  scope :stubs, -> { where(state: 'stub') }
  scope :recent, -> { order updated_at: :desc }

  STATES = %w[active inactive draft stub].freeze

  belongs_to :funder

  has_many :assessments, dependent: :destroy
  has_many :enquiries, dependent: :destroy
  has_many :requests, dependent: :destroy

  has_many :fund_themes, dependent: :destroy
  has_many :themes, through: :fund_themes

  belongs_to :geo_area
  has_many :countries, through: :geo_area
  has_many :districts, through: :geo_area

  has_many :questions
  accepts_nested_attributes_for :questions, allow_destroy: true
  has_many :restrictions, through: :questions, source: :criterion, source_type: 'Restriction'
  has_many :priorities, through: :questions, source: :criterion, source_type: 'Priority'

  validates :funder, :slug, :name, :description, :currency,
            :key_criteria, :application_link, :themes,
            presence: true

  validates :open_call, :restrictions_known, :featured,
            inclusion: { in: [true, false] }

  validates :state, inclusion: { in: STATES }

  validates :name, uniqueness: { scope: :funder }

  validates :restrictions, presence: true, if: :restrictions_known?
  validates :priorities, presence: true, if: :priorities_known?

  validates :open_data, :period_start, :period_end,
            :amount_awarded_distribution, :award_month_distribution,
            :country_distribution, :sources,
            presence: true, if: :open_data?
  validates :grant_count, presence: true,
                          numericality: { greater_than_or_equal_to: 0 },
                          if: :open_data?

  validates :min_amount_awarded, presence: true, if: :min_amount_awarded_limited
  validates :max_amount_awarded, presence: true, if: :max_amount_awarded_limited
  validates :min_org_income, presence: true, if: :min_org_income_limited
  validates :max_org_income, presence: true, if: :max_org_income_limited
  validates :min_duration_awarded, presence: true,
                                   if: :min_duration_awarded_limited
  validates :max_duration_awarded, presence: true,
                                   if: :max_duration_awarded_limited

  validates :permitted_org_types, array: { in: ORG_TYPES.pluck(1) }
  validates :permitted_costs, array: { in: FUNDING_TYPES.pluck(1) }

  validate :validate_sources, :validate_districts
  validate :period_start_before_period_end, :period_end_in_past, if: :open_data?

  attr_accessor :skip_beehive_data

  before_validation :set_slug, unless: :slug
  before_validation :check_beehive_data,
                    if: proc { |o| o.skip_beehive_data.to_i.zero? }

  def save(*args)
    if state =~ /draft|stub/ && FundStub.new(fund: self).valid?
      set_slug unless slug
      super(validate: false)
    else
      super
    end
  end

  def self.version
    XXhash.xxh32(active.order(:updated_at).pluck(:updated_at).join)
  end

  def self.join(proposal = nil)
    joins(
      'LEFT JOIN assessments ' \
      'ON funds.id = assessments.fund_id ' \
      "AND assessments.proposal_id = #{proposal&.id || 'NULL'}"
    )
  end

  def self.order_by(col = nil)
    order = [
      'funds.featured DESC',
      'assessments.revealed',
      ('assessments.eligibility_status DESC' unless col == 'name'),
      'funds.name'
    ]
    order(*order)
  end

  def self.country(state = nil)
    state.blank? ? all : joins(:countries).where('countries.alpha2': state)
  end

  def self.eligibility(state = nil)
    eligibility = {
      'eligible'   => ELIGIBLE,
      'ineligible' => INELIGIBLE,
      'to-check'   => [UNASSESSED, INCOMPLETE]
    }[state]

    eligibility ? where('assessments.eligibility_status': eligibility) : all
  end

  def self.funding_type(state = nil)
    type = { 'capital' => 1, 'revenue' => 2 }[state]
    type ? where("permitted_costs @> '[#{type}]'") : all
  end

  def self.revealed(state)
    state.to_s == 'true' ? where('assessments.revealed': state) : all
  end

  def assessment
    return unless respond_to?(:assessment_id)
    OpenStruct.new(
      id: assessment_id,
      fund_id: hashid,
      proposal_id: proposal_id,
      eligibility_status: eligibility_status,
      revealed: revealed
    )
  end

  def to_param
    hashid
  end

  def pretty_name
    super.blank? ? 'Hidden fund' : super
  end

  def short_name
    name.sub(' Fund', '')
  end

  def title
    funder.funds.size > 1 ? name : funder.name
  end

  def subtitle
    funder.funds.size > 1 ? funder.name : name
  end

  def tags?
    tags.count.positive?
  end

  def stub?
    %w[stub draft].include? state
  end

  def key_criteria_html
    markdown(key_criteria)
  end

  def description_html
    markdown(description)
  end

  def amount_desc # TODO: refactor & test
    return 'of any size' unless min_amount_awarded_limited || max_amount_awarded_limited
    opts = { precision: 0, unit: '£' }
    if !min_amount_awarded_limited || min_amount_awarded.zero?
      "up to #{number_to_currency(max_amount_awarded, opts)}"
    elsif !max_amount_awarded_limited
      "more than #{number_to_currency(min_amount_awarded, opts)}"
    else
      "between #{number_to_currency(min_amount_awarded, opts)} and #{number_to_currency(max_amount_awarded, opts)}"
    end
  end

  def duration_desc # TODO: refactor & test
    return unless min_duration_awarded_limited || max_duration_awarded_limited
    if !min_duration_awarded_limited || min_duration_awarded == 0
      "up to #{months_to_str(max_duration_awarded)}"
    elsif !max_duration_awarded_limited
      "more than #{months_to_str(min_duration_awarded)}"
    else
      "between #{months_to_str(min_duration_awarded)} and #{months_to_str(max_duration_awarded)}"
    end
  end

  def org_income_desc # TODO: refactor & test
    return 'any' unless min_org_income_limited || max_org_income_limited
    opts = {precision: 0, unit: "£"}
    if !min_org_income_limited || min_org_income == 0
      "up to #{number_to_currency(max_org_income, opts)}"
    elsif !max_org_income_limited
      "more than #{number_to_currency(min_org_income, opts)}"
    else
      "between #{number_to_currency(min_org_income, opts)} and #{number_to_currency(max_org_income, opts)}"
    end
  end

  def question_groups(question_type)
    case question_type
    when 'Restriction'
      restrictions.pluck(:category).uniq
    else
      questions.where(criterion_type: question_type).pluck(:group).uniq
    end
  end

  include FundJsonSetters
  include FundArraySetters

  private

    def set_slug
      self[:slug] = "#{funder.slug}-#{name.parameterize}" if funder
    end

    def period_end_in_past
      return unless period_end
      errors.add(:period_end, 'Period end must be in the past') if
        period_end > Time.zone.today
    end

    def period_start_before_period_end
      return unless period_start && period_end
      errors.add(:period_start, 'Period start must be before period end') if
        period_start > period_end
    end

    def months_to_str(months)
      if months == 12
        '1 year'
      elsif months < 24
        "#{months} months"
      elsif (months % 12).zero?
        "#{months / 12} years"
      else
        "#{months_to_str(months - (months % 12))} and #{months % 12} months"
      end
    end

    def check_beehive_data # TODO: refactor as service
      return unless open_data && slug
      options = {
        headers: {
          'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN']
        }
      }
      resp = HTTParty.get(
        ENV['BEEHIVE_DATA_FUND_SUMMARY_ENDPOINT'] + slug, options
      )
      # attributes we're looking for in the response
      resp_attributes = %w(
        amount_awarded_distribution
        award_month_distribution
        org_type_distribution
        income_distribution
        country_distribution
        sources
        grant_count
        period_end
        period_start
        beneficiary_distribution
        grant_examples
        amount_awarded_sum
      )
      assign_attributes(resp.slice(*resp_attributes)) if slug == resp['fund_slug']
    end

    def validate_sources # TODO: refactor DRY
      sources.try(:each) do |k, v|
        errors.add(:sources, "Invalid URL - key: #{k}") if
          k !~ %r{https?://}
        errors.add(:sources, "Invalid URL - value: #{v}") if
          v !~ %r{https?://}
      end
    end

    def validate_districts
      return if countries.empty?
      state = [geographic_scale_limited?, national?]
      case state
      when [false, false] # anywhere
        errors.add(:districts, 'must be blank') unless districts.empty?
      when [false, true]  # invalid
        errors.add(:national, 'cannot be set unless geographic scale limited')
      when [true, true]   # national
        errors.add(:districts, 'must be blank for national funds') unless districts.empty?
      when [true, false]  # local
        countries.each do |country|
          errors.add(:districts, "for #{country.name} not selected") if
            (district_ids & country.district_ids).count.zero?
        end
      end
    end
end
