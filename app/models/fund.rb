class Fund < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :newer_than, ->(date) { where('updated_at > ?', date) }
  scope :recent, -> { order updated_at: :desc }

  belongs_to :funder

  has_many :enquiries, dependent: :destroy

  has_many :fund_themes, dependent: :destroy
  has_many :themes, through: :fund_themes

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :restrictions
  accepts_nested_attributes_for :restrictions

  validates :funder, :type_of_fund, :slug, :name, :description, :currency,
            :key_criteria, :application_link, :countries, :themes,
            presence: true

  validates :open_call, :active, :restrictions_known,
            inclusion: { in: [true, false] }

  validates :name, uniqueness: { scope: :funder }

  validates :restrictions, presence: true, if: :restrictions_known?
  validates :restrictions_known, presence: true, if: :restriction_ids?

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
  before_save :set_restriction_ids, if: :restrictions_known?

  def self.order_by(proposal, col)
    case col
    when 'name'
      order col
    else
      suitable_funds = proposal.suitable_funds.pluck(0)

      all.sort_by do |fund|
        suitable_funds.index(fund.slug) || suitable_funds.size + 1
      end
    end
  end

  def self.eligibility(proposal, state)
    case state
    when 'eligible'
      where slug: proposal.eligible_funds.keys
    when 'ineligible'
      where slug: proposal.ineligible_funds.keys
    else
      all
    end
  end

  def self.duration(proposal, state)
    case state
    when 'up-to-2y'
      where '
        min_duration_awarded <= 24 OR
        (max_duration_awarded IS NOT NULL AND min_duration_awarded IS NULL)
      '
    when '2y-plus'
      where 'max_duration_awarded > 24'
    when 'proposal'
      where '
        (min_duration_awarded iS NOT NULL OR max_duration_awarded IS NOT NULL) AND
        (min_duration_awarded <= :proposal OR min_duration_awarded IS NULL) AND
        (max_duration_awarded >= :proposal OR max_duration_awarded IS NULL)
      ', proposal: proposal.funding_duration
    else
      all
    end
  end

  def to_param
    slug
  end

  def short_name
    name.sub(' Fund', '')
  end

  def tags?
    tags.count.positive?
  end

  def key_criteria_html
    markdown(key_criteria)
  end

  def description_html
    markdown(description)
  end

  include FundJsonSetters
  include FundArraySetters

  private

    def set_slug
      self[:slug] = "#{funder.slug}-#{name.parameterize}" if funder
    end

    def set_restriction_ids
      self[:restriction_ids] = restrictions.pluck(:id)
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
