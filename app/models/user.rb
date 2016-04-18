class User < ActiveRecord::Base

  belongs_to :organisation
  has_many :feedbacks

  JOB_ROLES = ['Fundraiser', 'Founder/Leader', 'Trustee', "None, I don't work/volunteer for a non-profit", 'Other']

  attr_accessor :org_type, :charity_number, :company_number

  validates :org_type, inclusion: { in: %w[0 1 2 3 4], message: 'Please select a valid option' }, on: :create
  validates :charity_number, presence: { message: "Can't be blank" }, if: Proc.new { |o| o.org_type == '1' || o.org_type == '3' }
  validates :company_number, presence: { message: "Can't be blank" }, if: Proc.new { |o| o.org_type == '2' || o.org_type == '3' }

  validates :org_type, presence: { message: "Can't be blank" }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, on: :create

  validates :first_name, :last_name, :user_email, :role, :agree_to_terms,
            presence: { message: "Can't be blank" }, on: :create

  validates :first_name, :last_name,
            format: {with: /\A(([a-z]+)*(-)*)+\z/i, message: 'Only a-z and -'}, on: :create

  validates :user_email,
            format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
            message: 'Please enter a valid email'}, on: :create
  validates :user_email, uniqueness: { message: "Please 'sign in' using the link above" }, on: :create

  validates :password, presence: { message: "Can't be blank" }, length: {:within => 6..25}, on: [:create, :update]
  validates :password,
            format: {with: /\A(?=.*\d)(?=.*[a-zA-Z]).{6,25}\z/,
            message: 'Must include 6 characters with 1 number'}, on: [:create, :update]

  validate  :no_organisation_declared

  before_create { generate_token(:auth_token) }

  def first_name=(s)
    write_attribute(:first_name, s.to_s.strip.capitalize)
  end

  def last_name=(s)
    write_attribute(:last_name, s.to_s.strip.capitalize)
  end

  def user_email=(s)
    write_attribute(:user_email, s.downcase)
  end

  def full_name
    name = "#{first_name} #{last_name}"
  end

  has_secure_password

  def lock_access_to_organisation(organisation)
    generate_token(:unlock_token)
    self.authorised = false
    self.organisation_id = organisation.id
    save(validate: false)
    organisation.send_authorisation_email(self)
  end

  def unlock
    self.update_attribute(:authorised, true)
    UserMailer.notify_unlock(self).deliver
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save(validate: false)
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  private

  def no_organisation_declared
    errors.add(:job_role, '') if job_role == "None, I don't work/volunteer for a non-profit"
  end

end
