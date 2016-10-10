class Fund < ActiveRecord::Base

  belongs_to :funder

  has_many :recommendations, dependent: :destroy
  has_many :proposals, through: :recommendations

  has_many :enquiries, dependent: :destroy
  has_many :deadlines, dependent: :destroy
  # TODO: accepts_nested_attributes_for :deadlines, allow_destroy: true
  has_many :stages, dependent: :destroy
  # TODO: accepts_nested_attributes_for :stages

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :funding_types
  has_and_belongs_to_many :restrictions
  accepts_nested_attributes_for :restrictions
  # TODO: has_and_belongs_to_many :proposal_restrictions
  has_and_belongs_to_many :outcomes
  has_and_belongs_to_many :decision_makers

  acts_as_taggable

  validates :funder, :type_of_fund, :slug, :name, :description, :currency,
            :key_criteria, :application_link,
              presence: true

  validates :open_call, :active, :restrictions_known,
              inclusion: { in: [true, false] }

  validates :name, uniqueness: { scope: :funder }

  # TODO:
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
  # validates :duration_months_min, presence: true, if: :duration_months_min_limited?
  # validates :duration_months_max, presence: true, if: :duration_months_max_limited?
  #
  # validates :deadlines_known, :stages_known, inclusion: { in: [true, false] }
  #
  # validates :deadlines, presence: true,
  #             if: :deadlines_known? && :deadlines_limited?
  #
  # validates :stages, :stages_count, presence: true,
  #             if: :stages_known?
  #
  # validates :accepts_calls, presence: true, if: :accepts_calls_known?
  # validates :contact_number, presence: true, if: :accepts_calls?
  #
  # validates :geographic_scale, numericality: { only_integer: true, greater_than_or_equal_to: Proposal::AFFECT_GEO.first[1], less_than_or_equal_to: Proposal::AFFECT_GEO.last[1] }
  #
  # validates :countries, :districts, presence: true, if: :geographic_scale_limited?
  validates :restrictions, presence: true, if: :restrictions_known?
  # validates :outcomes, presence: true, if: :outcomes_known?
  # validates :decision_makers, presence: true, if: :decision_makers_known?

  # with open_data

  validates :open_data, :period_start, :period_end,
            :amount_awarded_distribution, :award_month_distribution,
            :country_distribution,
              presence: true, if: :open_data?
  validates :grant_count,
              presence: true, numericality: { greater_than_or_equal_to: 0 }, if: :open_data?

  # TODO:
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
  #             presence: true, numericality: { greater_than_or_equal_to: 0 }, if: :open_data?

  validate :period_start_before_period_end, :period_end_in_past, if: :open_data?

  attr_accessor :skip_beehive_data

  before_validation :set_slug, unless: :slug
  before_validation :check_beehive_data, if: Proc.new { |o| o.skip_beehive_data == '0' }

  def to_param
    self.slug
  end

  def short_name
    self.name.sub(' Fund', '')
  end

  private

    def set_slug
      self.slug = "#{self.funder.slug}-#{self.name.parameterize}" if self.funder
    end

    def period_end_in_past
      if period_end
        errors.add(:period_end, 'Period end must be in the past') if period_end > Date.today
      end
    end

    def period_start_before_period_end
      if period_start && period_end
        errors.add(:period_start, 'Period start must be before period end') if period_start > period_end
      end
    end

    def check_beehive_data
      if self.open_data && self.slug
        options = {
          headers: { 'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN'] }
        }
        resp = HTTParty.get(ENV['BEEHIVE_DATA_FUND_SUMMARY_ENDPOINT'] + self.slug, options)
        self.assign_attributes(resp.except('fund_slug')) if self.slug == resp['fund_slug']
      end
    end

end
