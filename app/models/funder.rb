class Funder < Organisation
  has_many :grants
  has_many :features
  has_many :funder_attributes, dependent: :destroy

  has_many :recipients, :through => :grants
  has_many :profiles, :through => :recipients

  alias_method :attributes, :funder_attributes
end
