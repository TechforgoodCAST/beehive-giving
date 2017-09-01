class Theme < ApplicationRecord
  belongs_to :parent, class_name: 'Theme', optional: true

  has_many :fund_themes, dependent: :destroy
  has_many :funds, through: :fund_themes

  validates :name, :slug, uniqueness: true
  # See app/validators/hash_validator.rb
  validates :related, hash: { key_in: pluck(:name), value_in: :number }

  before_validation :set_slug

  def to_param
    slug
  end

  private

    def set_slug
      self[:slug] = name.parameterize
    end
end
