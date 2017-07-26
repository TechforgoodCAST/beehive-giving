class Theme < ApplicationRecord
  belongs_to :parent, class_name: 'Theme', optional: true

  validates :name, uniqueness: true
end
