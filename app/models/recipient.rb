class Recipient < ApplicationRecord
  CATEGORIES = {
    'Unincorporated' => {
      201 => 'A community or voluntary group',
      202 => 'An unincorporated association',
      203 => 'An unregistered charity'
    },
    'Incorporated' => {
      301 => 'A charitable organisation',
      302 => 'A company',
      303 => 'An industrial and provident society (IPS)'
    },
    'Other' => {
      101 => 'An individual',
      102 => 'Another type of organisation'
    }
  }.freeze

  INCOME_BANDS = {
    0 => { label: 'Less than £10k', min: 0,          max: 9_999 },
    1 => { label: '£10k - £99k',    min: 10_000,     max: 99_999 },
    2 => { label: '£100k - £999k',  min: 100_000,    max: 999_999 },
    3 => { label: '£1m - £10m',     min: 1_000_000,  max: 10_000_000 },
    4 => { label: 'More than £10m', min: 10_000_001, max: Float::INFINITY }
  }.freeze

  OPERATING_FOR = {
    0 => 'Yet to start',
    1 => 'Less than 12 months',
    2 => 'Less than 3 years',
    3 => '4 years or more'
  }.freeze

  belongs_to :country
  belongs_to :district
  belongs_to :user, optional: true

  has_one :proposal

  has_many :assessments

  # TODO: is inverse_of required if rails updated?
  has_many :answers, as: :category, dependent: :destroy, inverse_of: :category
  accepts_nested_attributes_for :answers
  validates_associated :answers

  validates :category_code, :country, :district, presence: true

  validates :category_code, inclusion: {
    in: CATEGORIES.values.map(&:keys).flatten,
    message: 'please select an option'
  }

  with_options if: :incorporated? do
    validates :description, presence: true
  end

  with_options unless: :individual? do
    validates :name, presence: true

    validates :operating_for, inclusion: { in: OPERATING_FOR.keys }

    validates :income_band, inclusion: { in: INCOME_BANDS.keys }
  end

  validates :website, format: {
    with: URI.regexp(%w[http https]),
    message: 'enter a valid website address e.g. http://www.example.com'
  }, if: :website?

  def name=(s)
    self[:name] = s&.capitalize
  end

  def charity_number=(s)
    self[:charity_number] = s&.strip
  end

  def company_number=(s)
    self[:company_number] = s&.strip
  end

  def to_param
    hashid
  end

  # TODO: to concern
  # Lookup category name from {CATEGORIES} using #category_code.
  #
  # @return [String] the name of the category.
  def category_name
    CATEGORIES.values.reduce({}, :merge)[category_code]
  end

  def income_band_name
    INCOME_BANDS[income_band].try(:[], :label)
  end

  def individual?
    category_code == 101
  end

  def operating_for_name
    OPERATING_FOR[operating_for]
  end

  private

    def incorporated?
      category_code&.between?(301, 399)
    end
end
