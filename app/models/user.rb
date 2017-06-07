class User < ActiveRecord::Base
  scope :user, -> { where role: 'User' }
  scope :funder, -> { where role: 'Funder' }

  belongs_to :organisation
  has_many :feedbacks

  attr_accessor :org_type, :charity_number, :company_number

  validates :org_type, inclusion: {
    in: %w(0 1 2 3 4), message: 'Please select a valid option'
  }, on: :create
  validates :charity_number,
            presence: { message: "Can't be blank" },
            if: proc { |o| o.org_type == '1' || o.org_type == '3' }
  validates :company_number,
            presence: { message: "Can't be blank" },
            if: proc { |o| o.org_type == '2' || o.org_type == '3' }

  validates :org_type,
            presence: { message: "Can't be blank" },
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            on: :create

  validates :first_name, :last_name, :email, :role, :agree_to_terms,
            presence: { message: "Can't be blank" }, on: :create

  validates :first_name, :last_name, format: {
    with: /\A(([a-z]+)*(-)*)+\z/i, message: 'Only a-z and -'
  }, on: :create

  validates :email,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
                      message: 'Please enter a valid email' }, on: :create
  validates :email,
            uniqueness: { message: "Please 'sign in' using the link above" },
            on: :create

  validates :password, presence: { message: "Can't be blank" },
                       length: { within: 6..25 }, on: [:create, :update]
  validates :password,
            format: { with: /\A(?=.*\d)(?=.*[a-zA-Z]).{6,25}\z/,
                      message: 'Must include 6 characters with 1 number' },
            on: [:create, :update]

  before_create { generate_token(:auth_token) }

  has_secure_password

  def first_name=(s)
    self[:first_name] = s.to_s.strip.capitalize
  end

  def last_name=(s)
    self[:last_name] = s.to_s.strip.capitalize
  end

  def email=(s)
    self[:email] = s.downcase
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def lock_access_to_organisation(organisation)
    generate_token(:unlock_token)
    self.authorised = false
    self.organisation_id = organisation.id
    save(validate: false)
    organisation.send_authorisation_email(self)
  end

  def unlock
    update_attribute(:authorised, true)
    UserMailer.notify_unlock(self).deliver_now
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save(validate: false)
    UserMailer.password_reset(self).deliver_now
  end

  private

    def generate_token(column)
      loop do
        self[column] = SecureRandom.urlsafe_base64
        break unless User.exists?(column => self[column])
      end
    end
end
