class Fund < ActiveRecord::Base
  scope :active, -> { distinct.where(active: true) }
  scope :inactive_ids, -> { where(active: false).pluck(:id) }
  scope :newer_than, ->(date) { where('updated_at > ?', date) }

  belongs_to :funder

  has_many :proposals, through: :recommendations
  has_many :recommendations, dependent: :destroy
  has_many :enquiries, dependent: :destroy

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :funding_types
  has_and_belongs_to_many :restrictions
  accepts_nested_attributes_for :restrictions

  validates :funder, :type_of_fund, :slug, :name, :description, :currency,
            :key_criteria, :application_link,
            presence: true

  validates :open_call, :active, :restrictions_known,
            inclusion: { in: [true, false] }

  validates :name, uniqueness: { scope: :funder }

  # TODO: validations
  # validates :amount_min_limited, :amount_max_limited,
  #             inclusion: { in: [true, false] },
  #             if: :amount_known?
  #
  # validates :amount_min, presence: true, if: :amount_min_limited?
  # validates :amount_max, presence: true, if: :amount_max_limited?
  #
  # validates :duration_months_min_limited, :duration_months_max_limited,
  #             inclusion: { in: [true, false] },
  #             if: :duration_months_known?
  #
  # validates :duration_months_min, presence: true,
  #                                 if: :duration_months_min_limited?
  # validates :duration_months_max, presence: true,
  #                                 if: :duration_months_max_limited?
  #
  # validates :accepts_calls, presence: true, if: :accepts_calls_known?
  # validates :contact_number, presence: true, if: :accepts_calls?

  validates :countries, presence: true
  validates :restrictions, presence: true, if: :restrictions_known?
  validates :restrictions_known, presence: true, if: :restriction_ids?

  # with open_data

  validates :open_data, :period_start, :period_end,
            :amount_awarded_distribution, :award_month_distribution,
            :country_distribution, :sources,
            presence: true, if: :open_data?
  validates :grant_count, presence: true,
                          numericality: { greater_than_or_equal_to: 0 },
                          if: :open_data?

  validate :validate_sources, :validate_districts

  # TODO: validations
  # validates :period_start, :period_end, :org_type_distribution,
  #           :operating_for_distribution, :income_distribution,
  #           :employees_distribution, :volunteers_distribution,
  #           :geographic_scale_distribution, :gender_distribution,
  #           :age_group_distribution, :beneficiary_distribution,
  #           :amount_awarded_distribution, :award_month_distribution,
  #           :country_distribution, :district_distribution,
  #             presence: true, if: :open_data?
  #
  # validates :grant_count, :recipient_count,
  #           :amount_awarded_sum, :amount_awarded_mean, :amount_awarded_median,
  #           :amount_awarded_min, :amount_awarded_max,
  #           :duration_awarded_months_mean, :duration_awarded_months_median,
  #           :duration_awarded_months_min, :duration_awarded_months_max,
  #           presence: true, numericality: { greater_than_or_equal_to: 0 },
  #           if: :open_data?

  validate :period_start_before_period_end, :period_end_in_past, if: :open_data?

  attr_accessor :skip_beehive_data

  before_validation :set_slug, unless: :slug
  before_validation :check_beehive_data,
                    if: proc { |o| o.skip_beehive_data.to_i.zero? }
  before_save :set_restriction_ids, if: :restrictions_known?

  def to_param
    slug
  end

  def short_name
    name.sub(' Fund', '')
  end

  def tags?
    tags.count.positive?
  end

  include JsonSetters

  private

    def set_slug
      self.slug = "#{funder.slug}-#{name.parameterize}" if funder
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

    def check_beehive_data
      return unless open_data && slug
      options = {
        headers: {
          'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN']
        }
      }
      resp = HTTParty.get(
        ENV['BEEHIVE_DATA_FUND_SUMMARY_ENDPOINT'] + slug, options
      )
      assign_attributes(resp.except('fund_slug')) if slug == resp['fund_slug']
    end

    def set_restriction_ids
      self[:restriction_ids] = restrictions.pluck(:id)
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
