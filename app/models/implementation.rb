class Implementation < ApplicationRecord
  IMPLEMENTATIONS = [
    { label: 'Buildings/facilities' },
    { label: 'Campaigns' },
    { label: 'Finance' },
    { label: 'Membership' },
    { label: 'Products' },
    { label: 'Research' },
    { label: 'Services' },
    { label: 'Software' }
  ].freeze

  has_and_belongs_to_many :proposals
  has_and_belongs_to_many :profiles # TODO: deprecated

  validates :label, presence: true
end
