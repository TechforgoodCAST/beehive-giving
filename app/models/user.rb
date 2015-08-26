class User < ActiveRecord::Base

  belongs_to :organisation
  has_many :feedbacks

  JOB_ROLES = ['Fundraiser', 'Founder/Leader', "None, I don't work/volunteer for a non-profit", 'Other']

  validates :first_name, :last_name, :user_email, :role, :job_role, :agree_to_terms,
            presence: true, on: :create

  validates :first_name, :last_name,
            format: {with: /\A[a-z]+\z/i, message: 'invalid name'}, on: :create

  validates :job_role, inclusion: {in: JOB_ROLES}

  validates :user_email,
            format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
            message: 'please enter a valid email'}, on: :create
  validates :user_email, uniqueness: true, on: :create

  validates :password, presence: true, length: {:within => 6..25}, on: :create
  validates :password,
            format: {with: /\A(?=.*\d)(?=.*[a-zA-Z]).{6,25}\z/,
            message: 'must include 6 characters with 1 number'}, on: :create

  before_create { generate_token(:auth_token) }

  def first_name=(s)
    write_attribute(:first_name, s.to_s.capitalize)
  end

  def last_name=(s)
    write_attribute(:last_name, s.to_s.capitalize)
  end

  def full_name
    name = "#{first_name.capitalize} #{last_name.capitalize}"
  end

  has_secure_password

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

end
