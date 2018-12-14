class Proposal < ApplicationRecord
  include GenerateToken

  attr_accessor :country_id

  CATEGORIES = {
    'Grant funding' => {
      201 => 'Capital',
      202 => 'Revenue - Core',
      203 => 'Revenue - Project'
    },
    'Other' => {
      101 => 'Other'
    }
  }.freeze

  GEOGRAPHIC_SCALES = {
    local: 'One or more local areas',
    regional: 'One or more regions',
    national: 'An entire country',
    international: 'Across many countries'
  }.with_indifferent_access.freeze

  scope :recent_public, -> { where('private IS NULL').last(5).reverse }

  belongs_to :collection, polymorphic: true
  belongs_to :recipient
  belongs_to :user

  has_many :assessments, dependent: :destroy

  has_many :proposal_themes, dependent: :destroy
  has_many :themes, through: :proposal_themes

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  # TODO: is inverse_of required if rails updated?
  has_many :answers, as: :category, dependent: :destroy, inverse_of: :category
  accepts_nested_attributes_for :answers, :user
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
    in: CATEGORIES.values.map(&:keys).flatten,
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

  with_options if: :local_or_regional? do
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

  before_validation :clear_districts_if_country_wide, :country_to_countries

  before_create { generate_token(:access_token) }

  # TODO: to concern
  # Lookup category name from {CATEGORIES} using #category_code.
  #
  # @return [String] the name of the category.
  def category_name
    CATEGORIES.values.reduce({}, :merge)[category_code]
  end

  def description_with_default
    description || '<em>No description provided</em>'.html_safe
  end

  def identifier
    "##{id}"
  end

  def name
    if collection_type
      "#{collection_type} report for #{collection.name}"
    else
      'Report'
    end
  end

  def save(*args)
    existing_user = User.find_by(email: user.email) if user&.email
    if existing_user
      self.user = existing_user
      user.skip_validations = true
    end
    super
  end

  def seeking_funding?
    category_code&.between?(201, 299)
  end

  def status
    if collection_type
      private? ? 'private' : 'public'
    else
      'legacy'
    end
  end

  def title_with_default
    title || '<em>No title provided</em>'.html_safe
  end

  private

    def clear_districts_if_country_wide
      self.districts = [] if national? || international?
    end

    def country_to_countries
      return if country_id.nil?

      self.country_ids = [country_id] unless international?
    end

    def international?
      geographic_scale == 'international'
    end

    def local_or_regional?
      %w[local regional].include?(geographic_scale)
    end

    def national?
      geographic_scale == 'national'
    end

    def other_support?
      category_code&.between?(101, 199)
    end
end
