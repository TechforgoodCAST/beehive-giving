class Funder < Organisation
  has_many :grants
  has_many :features
  has_and_belongs_to_many :restrictions
  has_many :enquiries
  has_many :funder_attributes, dependent: :destroy

  has_many :recipients, :through => :grants
  has_many :profiles, :through => :recipients

  has_many :approval_months, :through => :funder_attributes

  alias_method :attributes, :funder_attributes
end
