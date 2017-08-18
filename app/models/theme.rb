class Theme < ApplicationRecord
  belongs_to :parent, class_name: 'Theme', optional: true

  has_many :fund_themes, dependent: :destroy
  has_many :funds, through: :fund_themes

  validates :name, uniqueness: true
  validates :slug, uniqueness: true
  validates :slug, presence: true
  # See app/validators/hash_validator.rb
  validates :related, hash: { key_in: pluck(:name), value_in: :number }

  before_validation :set_slug

  private

      def set_slug
        self[:slug] = name.parameterize
      end
end
