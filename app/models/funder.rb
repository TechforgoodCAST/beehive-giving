class Funder < Organisation
  has_many :grants
  has_many :features
  has_one :funder_attributes

  alias_method :attributes, :funder_attributes
end
