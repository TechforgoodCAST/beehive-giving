class Fund < ApplicationRecord
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

  validates :proposal_all_in_area, absence: true, unless: :proposal_area_limited

  validates :geo_area, presence: true, if: :proposal_area_limited

  validate :validate_integer_rules, :validate_links

  # TODO: review
  def self.version
    XXhash.xxh32(active.order(:updated_at).pluck(:updated_at).join)
  end

  def description_html
    markdown(description)
  end

  # TODO: remove
  def description_plain
    markdown(description, plain: true)
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
