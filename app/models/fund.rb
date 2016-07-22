class Fund < ActiveRecord::Base

  belongs_to :funder

  has_many :deadlines
  has_many :stages

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :funding_types
  has_and_belongs_to_many :restrictions
  has_and_belongs_to_many :outcomes
  has_and_belongs_to_many :decision_makers

  validates :funder, :type_of_fund, :year_of_fund, :slug, :name, :description,
            :open_call, :active, :currency, :funding_types,
              presence: true

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

  before_validation :set_slug, unless: :slug

  private

    def to_param
      self.slug
    end

    def set_slug
      self.slug = "#{self.funder.slug}-#{self.name.parameterize}" if self.funder
    end

end
