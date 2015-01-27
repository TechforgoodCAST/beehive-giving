class Organisation < ActiveRecord::Base
  has_many :users
  has_many :profiles

  STATUS = ['Active', 'Closed', 'Merged']

  validates :name, :contact_number, :website, :street_address, :city, :region,
  :postal_code, :country, :founded_on, :mission, :status, presence: true
  validates :registered, :inclusion => {in: [true, false]}

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

  def self.search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
end
