class User < ApplicationRecord
  include GenerateToken

  attr_accessor :email_confirmation, :password_confirmation

  has_many :proposals
  has_many :recipients

  validates :email, presence: true, confirmation: true
  validates :email, uniqueness: { message: 'email already registered' }
  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: 'please enter a valid email'
  }

  validates :email_confirmation, presence: true, on: :create

  validates :first_name, :last_name, presence: true

  validates :marketing_consent, inclusion: {
    in: [true, false], message: 'please select an option'
  }

  validates :password, presence: true, confirmation: true, length: {
    in: 6..35
  }, on: :update
  validates :password, format: {
    with: /\A(?=.*\d)(?=.*[a-zA-Z]).{6,25}\z/,
    message: 'must include 6 characters with 1 number'
  }, on: :update

  validates :password_confirmation, presence: true, on: :update

  validates :terms_agreed, presence: {
    message: 'you must accept terms to continue'
  }

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

  before_create { generate_token(:auth_token) }

  has_secure_password validations: false
end
