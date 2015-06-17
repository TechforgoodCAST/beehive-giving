class Funder < Organisation

  has_many :grants
  has_many :countries, :through => :grants
  has_many :districts, :through => :grants

  has_many :features
  has_many :enquiries

  has_many :funder_attributes, dependent: :destroy
  has_many :approval_months, :through => :funder_attributes
  has_many :beneficiaries, :through => :funder_attributes

  has_many :recipients, :through => :grants
  has_many :profiles, :through => :recipients, dependent: :destroy

  has_and_belongs_to_many :funding_streams
  has_many :restrictions, :through => :funding_streams

  alias_method :attributes, :funder_attributes

  has_many :recommendations

end
