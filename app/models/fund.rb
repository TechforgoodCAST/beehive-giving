class Fund < ApplicationRecord
  extend Funds::FilterSort # TODO: review

  scope :active, -> { where(state: 'active') }
  scope :recent, -> { order updated_at: :desc } # TODO: review

  STATES = %w[active draft inactive].freeze

  belongs_to :funder
  belongs_to :geo_area, optional: true

  has_many :assessments, dependent: :destroy
  has_many :countries, through: :geo_area
  has_many :districts, through: :geo_area
  has_many :fund_themes, dependent: :destroy
  has_many :themes, through: :fund_themes

  has_many :questions
  accepts_nested_attributes_for :questions, allow_destroy: true

  has_many :criteria, through: :questions
  has_many :restrictions, through: :questions, source: :criterion,
                          source_type: 'Restriction'
  has_many :priorities, through: :questions, source: :criterion,
                        source_type: 'Priority'

  validates :name, presence: true, uniqueness: { scope: :funder }

  validates :description, :themes, presence: true

  validates :website, format: {
    with: URI.regexp(%w[http https]),
    message: 'enter a valid website address e.g. http://www.example.com'
  }

  validates :state, inclusion: { in: STATES }

  validates :recipient_categories, array: {
    in: Recipient::CATEGORIES.values.map(&:keys).flatten
  }, if: ->(o) { o.recipient_categories.any? }

  validates :proposal_categories, array: {
    in: Proposal::CATEGORIES.values.map(&:keys).flatten
  }, if: ->(o) { o.proposal_categories.any? }

  validates :proposal_permitted_geographic_scales, array: {
    in: Proposal::GEOGRAPHIC_SCALES.keys
  }, if: ->(o) { o.proposal_permitted_geographic_scales.any? }

  validates :proposal_all_in_area, inclusion: {
    in: [true, false]
  }, if: :proposal_area_limited

  validates :geo_area, presence: true, if: :proposal_area_limited

  validate :validate_integer_rules, :validate_links

  # TODO: review
  def self.version
    XXhash.xxh32(active.order(:updated_at).pluck(:updated_at).join)
  end

  # TODO: refactor & test
  def amount_desc
    return 'of any size' unless min_amount_awarded_limited ||
                                max_amount_awarded_limited

    opts = { precision: 0, unit: '£' }
    if !min_amount_awarded_limited || min_amount_awarded.zero?
      "up to #{number_to_currency(max_amount_awarded, opts)}"
    elsif !max_amount_awarded_limited
      "more than #{number_to_currency(min_amount_awarded, opts)}"
    else
      "between #{number_to_currency(min_amount_awarded, opts)} and " \
      "#{number_to_currency(max_amount_awarded, opts)}"
    end
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

  def description_html
    markdown(description)
  end

  # TODO: remove
  def description_plain
    markdown(description, plain: true)
  end

  # TODO: refactor & test
  def org_income_desc
    return 'any' unless min_org_income_limited || max_org_income_limited

    opts = { precision: 0, unit: '£' }
    if !min_org_income_limited || min_org_income.zero?
      "up to #{number_to_currency(max_org_income, opts)}"
    elsif !max_org_income_limited
      "more than #{number_to_currency(min_org_income, opts)}"
    else
      "between #{number_to_currency(min_org_income, opts)} and " \
      "#{number_to_currency(max_org_income, opts)}"
    end
  end

  def to_param
    hashid
  end

  private

    def validate_integer_rules
      %i[
        proposal_min_amount proposal_max_amount proposal_min_duration
        proposal_max_duration recipient_min_income recipient_max_income
      ].each do |column|
        validates_numericality_of(column, only_integer: true) if send(column)
      end
    end

    def validate_links
      links.try(:each) do |_k, v|
        errors.add(:links, "#{v} must begin with http:// or https://") if
          v !~ %r{https?://}
      end
    end
end
