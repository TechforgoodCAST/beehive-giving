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

    validates :operating_for, inclusion: { in: OPERATING_FOR.pluck(1) }

    validates :income_band, inclusion: { in: INCOME_BANDS.pluck(1) }
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

  def max_income # TODO: review
    income || INCOME_BANDS[income_band][3]
  end

  def min_income # TODO: review
    income || INCOME_BANDS[income_band][2]
  end

  def send_authorisation_email(user_to_authorise) # TODO: review
    UserMailer.request_access(self, user_to_authorise).deliver_now
  end

  private

    def incorporated?
      category_code&.between?(301, 399)
    end

    def individual?
      category_code == 101
    end
end
