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

  validates :password, presence: true, confirmation: true, length: { in: 6..35 }
  validates :password, format: {
    with: /\A(?=.*\d)(?=.*[a-zA-Z]).{6,25}\z/,
    message: 'must include 6 characters with 1 number'
  }

  validates :password_confirmation, presence: true, on: :update

  validates :terms_agreed, presence: {
    message: 'you must accept terms to continue'
  }

  def email=(s)
    self[:email] = s&.downcase
  end

  def first_name=(s)
    self[:first_name] = s&.strip&.capitalize
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def last_name=(s)
    self[:last_name] = s&.strip&.capitalize
  end

  def terms_agreed=(bool)
    self[:terms_agreed] = bool.is_a?(TrueClass) ? Time.zone.now : nil
  end

  before_create { generate_token(:auth_token) }

  has_secure_password
end
