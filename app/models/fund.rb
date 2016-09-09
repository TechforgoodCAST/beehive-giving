class Fund < ActiveRecord::Base

  belongs_to :funder

  has_many :recommendations, dependent: :destroy
  has_many :proposals, through: :recommendations

  has_many :deadlines, dependent: :destroy
  has_many :stages, dependent: :destroy

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :funding_types
  has_and_belongs_to_many :restrictions
  has_and_belongs_to_many :outcomes
  has_and_belongs_to_many :decision_makers

  acts_as_taggable

  validates :funder, :type_of_fund, :slug, :name, :description,
            :open_call, :active, :currency, :funding_types,
              presence: true

  validates :name, uniqueness: { scope: :funder }

  validates :amount_min_limited, :amount_max_limited,
              inclusion: { in: [true, false] },
              if: :amount_known?

  validates :amount_min, presence: true, if: :amount_min_limited?
  validates :amount_max, presence: true, if: :amount_max_limited?

  validates :duration_months_min_limited, :duration_months_max_limited,
              inclusion: { in: [true, false] },
              if: :duration_months_known?

  validates :duration_months_min, presence: true, if: :duration_months_min_limited?
  validates :duration_months_max, presence: true, if: :duration_months_max_limited?

  validates :deadlines_known, :stages_known, inclusion: { in: [true, false] }

  validates :deadlines, presence: true,
              if: :deadlines_known? && :deadlines_limited?

  validates :stages, presence: true, if: :stages_known?
  validates :accepts_calls, presence: true, if: :accepts_calls_known?
  validates :contact_number, presence: true, if: :accepts_calls?

  validates :geographic_scale, numericality: { only_integer: true, greater_than_or_equal_to: Proposal::AFFECT_GEO.first[1], less_than_or_equal_to: Proposal::AFFECT_GEO.last[1] }

  validates :countries, :districts, presence: true, if: :geographic_scale_limited?
  validates :restrictions, presence: true, if: :restrictions_known?
  validates :outcomes, presence: true, if: :outcomes_known?
  validates :decision_makers, presence: true, if: :decision_makers_known?

  # with open_data

  validates :period_start, :period_end, :org_type_distribution,
            :operating_for_distribution, :income_distribution,
            :employees_distribution, :volunteers_distribution,
            :geographic_scale_distribution, :gender_distribution,
            :amount_awarded_distribution, :award_month_distribution,
            :country_distribution,
              presence: true, if: :open_data?

  validates :grant_count, :recipient_count, :amount_mean_historic,
            :amount_median_historic, :amount_min_historic, :amount_max_historic,
            :duration_months_mean_historic, :duration_months_median_historic,
            :duration_months_min_historic, :duration_months_max_historic,
            :beneficiary_max_age_historic,
              presence: true, numericality: { greater_than: 0 }, if: :open_data?

  validates :beneficiary_min_age_historic,
              presence: true, numericality: { greater_than_or_equal_to: 0 }, if: :open_data?

  validates :amount_max_historic, numericality: { greater_than: :amount_min_historic },
              if: Proc.new { |o| o.amount_min_historic? && o.open_data? }
  validates :duration_months_max_historic, numericality: { greater_than: :duration_months_min_historic },
              if: Proc.new { |o| o.duration_months_min_historic? && o.open_data? }
  validates :beneficiary_max_age_historic, numericality: { greater_than: :beneficiary_min_age_historic },
              if: Proc.new { |o| o.beneficiary_min_age_historic? && o.open_data? }

  validate :period_start_before_period_end, :period_end_in_past, if: :open_data?

  before_validation :set_slug, unless: :slug

  def to_param
    self.slug
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

end
