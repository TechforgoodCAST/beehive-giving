class Theme < ApplicationRecord
  belongs_to :parent, class_name: 'Theme', optional: true

  has_many :fund_themes, dependent: :destroy
  has_many :funds, through: :fund_themes

  validates :name, uniqueness: true
  # See app/validators/hash_validator.rb
  validates :related, hash: { key_in: pluck(:name), value_in: :number }
end
