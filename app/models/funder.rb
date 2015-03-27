class Funder < Organisation
  has_many :grants
  has_many :features
  has_many :funder_attributes, dependent: :destroy

  alias_method :attributes, :funder_attributes
end
