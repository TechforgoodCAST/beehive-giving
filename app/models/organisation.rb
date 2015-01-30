class Organisation < ActiveRecord::Base
  has_many :users
  has_many :profiles

  STATUS = ['Active - currently operational', 'Closed - no longer operational', 'Merged - operating as a different entity']

  validates :name, :contact_number, :street_address, :city, :region,
  :postal_code, :country, :founded_on, :mission, :status, presence: true
  validates :registered, :inclusion => {in: [true, false]}

  validates :website, format: {
    with: /^((http:\/\/www\.)|(www\.)|(http:\/\/))[a-zA-Z0-9._-]+\.[a-zA-Z.]{2,5}$/,
    multiline: true,
    message: "enter a valid website address e.g. www.example.com"}, if: :website?
  validates :contact_number, format: {
    with: /(((\+44)? ?(\(0\))? ?)|(0))( ?[0-9]{3,4}){3}/,
    multiline: true,
    message: "enter a valid contact number"}

  # date_select currently not nil
  # validates :registered_on, presence: true, unless: :company_number? || :charity_number?

  validates :charity_number, :company_number, uniqueness: true, if: :registered?, allow_nil: true, allow_blank: true
  validates :charity_number, presence: true, unless: :company_number?, if: :registered?
  validates :company_number, presence: true, unless: :charity_number?, if: :registered?
  validates :registered_on, presence: true, if: :registered?

  validates :slug, uniqueness: true, presence: true
  validates :status, inclusion: {in: STATUS}

  validate :founded_on_before_registered_on

  before_validation :set_slug, unless: :slug

  def to_param
    self.slug
  end

  def set_slug
    self.slug = generate_slug
  end

  def generate_slug(n=1)
    return nil unless self.name
    candidate = self.name.downcase.gsub(/[^a-z0-9]+/, '-')
    candidate += "-#{n}" if n > 1
    return candidate unless Organisation.find_by_slug(candidate)
    generate_slug(n+1)
  end

  def founded_on_before_registered_on
    errors.add(:registered_on, "You can't be registered before being founded") if
      !registered_on.blank? and registered_on < founded_on
  end
end
