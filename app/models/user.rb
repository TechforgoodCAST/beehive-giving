class User < ApplicationRecord
  scope :recipient, -> { where organisation_type: 'Recipient' }
  scope :funder, -> { where organisation_type: 'Funder' }

  belongs_to :organisation, polymorphic: true, optional: true
  has_many :feedbacks

  has_many :recipients

  # TODO: add validations for association
  validates :first_name, :last_name, :email, :organisation_type,
            presence: true, on: :create

  validates :agree_to_terms, presence: {
    message: 'you must accept terms to continue'
  }

  validates :first_name, :last_name, format: {
    with: /\A(([a-z]+)*(-)*)+\z/i, message: 'only a-z and -'
  }, on: :create

  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: 'please enter a valid email'
  }, on: :create

  validates :email, uniqueness: {
    message: "email already registered, please 'sign in' using the link below"
  }, on: :create

  validates :password, presence: true, length: { within: 6..25 },
                       on: %i[create update]

  validates :password, format: {
    with: /\A(?=.*\d)(?=.*[a-zA-Z]).{6,25}\z/,
    message: 'must include 6 characters with 1 number'
  }, on: %i[create update]

  validates :marketing_consent, inclusion: {
    message: 'please select an option', in: [true, false]
  }, on: :create

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

  def funder?
    organisation_type == 'Funder'
  end

  def legacy?
    !(organisation.present? && organisation.proposals.any?)
  end

  # TODO: refactor/spec
  def lock_access_to_organisation(organisation)
    generate_token(:unlock_token)
    self.authorised = false
    self.organisation_id = organisation.id
    save(validate: false)
    organisation.send_authorisation_email(self)
  end

  # TODO: refactor/spec
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

  def subscription
    organisation&.subscription
  end

  def subscription_active?
    subscription.active?
  end

  def subscription_version
    subscription ? subscription.version : 2
  end

  def reveals
    organisation.reveals
  end

  private

    def generate_token(column)
      loop do
        self[column] = SecureRandom.urlsafe_base64
        break unless User.exists?(column => self[column])
      end
    end
end
