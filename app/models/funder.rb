class Funder < Organisation
  scope :active, -> { where(active_on_beehive: true) }

  has_many :funds
  has_many :restrictions, through: :funds
end
