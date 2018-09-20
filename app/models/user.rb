class User < ApplicationRecord
  include EmailFormatValidations
  include GenerateToken

  has_secure_password validations: false

  has_many :proposals
  has_many :recipients

  validates :email, confirmation: true
  validates :email, uniqueness: { message: 'email already registered' }

  validates :email_confirmation, presence: true, on: :create

  validates :first_name, :last_name, presence: true

  validates :marketing_consent, inclusion: {
    in: [true, false], message: 'please select an option'
  }

  validates :password, confirmation: true, length: {
    minimum: 6,
    maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
  }, format: {
    with: /\A(?=.*\d)(?=.*[a-zA-Z]).*\z/,
    message: 'must contain at least one number'
  }, allow_blank: true

  validates :password, presence: true, on: :update,
                       if: ->(u) { u.password_digest.blank? }

  validates :password_confirmation, presence: true,
                                    if: ->(u) { u.password.present? }

  validates :terms_agreed, presence: {
    message: 'you must accept terms to continue'
  }

  before_create { generate_token(:auth_token) }

  def email=(str)
    self[:email] = str&.downcase
  end

  def first_name=(str)
    self[:first_name] = str&.strip&.capitalize
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def last_name=(str)
    self[:last_name] = str&.strip&.capitalize
  end

  def terms_agreed
    self[:terms_agreed].is_a?(Time)
  end

  def terms_agreed=(value)
    bool = ActiveModel::Type::Boolean.new.cast(value)
    self[:terms_agreed] = bool.is_a?(TrueClass) ? Time.zone.now : nil
  end

  def terms_agreed_time
    self[:terms_agreed]
  end
end
