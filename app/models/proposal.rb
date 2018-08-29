class Proposal < ApplicationRecord
  include GenerateToken

  GEOGRAPHIC_SCALES = {
    local: 'One or more local areas',
    regional: 'One or more regions',
    national: 'An entire country',
    international: 'Across many countries'
  }.with_indifferent_access.freeze

  SUPPORT_TYPES = {
    'Grant funding' => {
      201 => 'Capital',
      202 => 'Revenue - Core',
      203 => 'Revenue - Project'
    },
    'Other' => {
      101 => 'Other'
    }
  }.freeze

  belongs_to :recipient
  belongs_to :user

  has_many :assessments
  has_many :enquiries, dependent: :destroy

  has_many :proposal_themes, dependent: :destroy
  has_many :themes, through: :proposal_themes

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  has_many :answers, as: :category, dependent: :destroy
  accepts_nested_attributes_for :answers

  validates_associated :answers, :user

  validates :description, :category_code, :public_consent, :title,
            presence: true

  validates :title, length: {
    maximum: 280, message: 'please use 280 characters or less'
  }

  validates :themes, length: {
    minimum: 1, maximum: 5, message: 'please select 1 - 5 themes'
  }

  validates :category_code, inclusion: {
    in: SUPPORT_TYPES.values.map(&:keys).flatten,
    message: 'please select an option'
  }

  with_options if: :other_support? do
    validates :support_details, presence: true
  end

  with_options if: :seeking_funding? do
    validates :min_amount, :max_amount, :min_duration, :max_duration,
              presence: true, numericality: { only_integer: true }

    validates :min_amount, numericality: { greater_than: 0 }
    validates :max_amount, numericality: {
      greater_than_or_equal_to: :min_amount
    }, if: :min_amount

    validates :min_duration, numericality: {
      greater_than: 0,
      less_than_or_equal_to: 120
    }
    validates :max_duration, numericality: {
      greater_than_or_equal_to: :min_duration,
      less_than_or_equal_to: 120
    }, if: :min_duration
  end

  validates :geographic_scale, inclusion: {
    in: GEOGRAPHIC_SCALES.keys, message: 'please select an option'
  }

  with_options if: :local? do
    validates :countries, length: {
      minimum: 1, maximum: 1, message: 'please select a country'
    }
    validates :districts, length: {
      minimum: 1, message: 'please select districts'
    }
  end

  with_options if: :national? do
    validates :countries, length: {
      minimum: 1, maximum: 1, message: 'please select a country'
    }
    validates :districts, length: {
      maximum: 0, message: 'please deselect all districts'
    }
  end

  with_options if: :international? do
    validates :countries, length: {
      minimum: 1, message: 'please select countries'
    }
    validates :districts, length: {
      maximum: 0, message: 'please deselect all districts'
    }
  end

  before_validation :clear_districts_if_country_wide

  before_create { generate_token(:access_token) }

  # Lookup category name from {SUPPORT_TYPES} using #category_code.
  #
  # @return [String] the name of the category.
  def category_name
    SUPPORT_TYPES.values.reduce({}, :merge)[category_code]
  end

  private

    def clear_districts_if_country_wide
      self.districts = [] if national? || international?
    end

    def international?
      geographic_scale == 'international'
    end

    def local?
      %w[local regional].include?(geographic_scale)
    end

    def national?
      geographic_scale == 'national'
    end

    def other_support?
      category_code&.between?(101, 199)
    end

    def seeking_funding?
      category_code&.between?(201, 299)
    end
end
