class Theme < ApplicationRecord
  scope :primary, -> { where('parent_id IS NULL') }

  belongs_to :parent, class_name: 'Theme', optional: true

  has_many :proposals, as: :collection # TODO: test

  has_many :themes, foreign_key: 'parent_id'
  has_many :fund_themes, dependent: :destroy
  has_many :funds, through: :fund_themes

  # TODO: test
  has_many :criteria, -> { distinct }, through: :funds
  has_many :priorities, -> { distinct }, through: :funds
  has_many :restrictions, -> { distinct }, through: :funds

  validates :name, :slug, uniqueness: true
  validates :classes, presence: true

  # TODO: drop column?
  # See app/validators/hash_validator.rb
  validates :related, hash: { key_in: pluck(:name), value_in: :number }

  before_validation :set_slug

  def primary_color
    nil
  end

  def secondary_color
    nil
  end

  def to_param
    slug
  end

  private

    def set_slug
      self[:slug] = name.parameterize
    end
end
