class Organisation < ActiveRecord::Base
  before_save :clear_registration_numbers_if_not_registered

  STATUS = ['Active - currently operational', 'Closed - no longer operational', 'Merged - operating as a different entity']

  has_one :subscription
  has_many :users, dependent: :destroy
  has_many :profiles, dependent: :destroy

  attr_accessor :skip_validation

  validates :name, :founded_on, :status, :country, presence: true,
    unless: :skip_validation

  validates :registered_on, presence: true, if: :registered?,
    unless: :skip_validation

  validates :registered, :inclusion => { in: [true, false] },
    unless: :skip_validation

  validates :status, inclusion: { in: STATUS },
    unless: :skip_validation

  validates :website, format: {
    with: /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\z/,
    message: 'enter a valid website address e.g. www.example.com'}, if: :website?

  validates :slug, uniqueness: true, presence: true

  validates :charity_number, :company_number, uniqueness: {:on => [:create]}, if: :registered?, allow_nil: true, allow_blank: true

  validate  :founded_on_before_registered_on, if: :registered?,
            unless: Proc.new { |organisation| organisation.founded_on.nil? }
  validates :charity_number, :company_number,
            presence: { message: "charity number of company required if registered" },
            if: Proc.new { |o|
              o.registered == true && (o.charity_number.blank? && o.company_number.blank?)
            }

  before_validation :set_slug, unless: :slug

  def name=(s)
    write_attribute(:name, s.sub(s.first, s.first.upcase))
  end

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

  # TODO
  def send_authorisation_email(to_authorise)
    # self.pending_authorisation_list.add(to_authorise)
    if self.users.empty
      send_authorisation_email_to_admin(to_authorise)
    else
      send_authorisation_email_to_users(to_authorise)
    end
  end

  private

  def founded_on_before_registered_on
    errors.add(:registered_on, "you can't be registered before being founded") if registered_on and registered_on < founded_on
  end

  def clear_registration_numbers_if_not_registered
    if self.registered? == false
      self.registered_on = nil
      self.charity_number = nil
      self.company_number = nil
    end
  end

  # TODO
  def send_authorisation_email_to_admin(user)
    User.find_by_role('Admin').each do |u|
      UserMailer.request_authorisation(u, self, user)
    end
  end

  def send_authorisation_email_to_users(user)
    self.users.each do |u|
      if u.authorised
        UserMailer.request_authorisation(u, self, user)
      end
    end
  end
end
