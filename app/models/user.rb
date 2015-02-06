class User < ActiveRecord::Base
  belongs_to :organisation
  has_many :feedbacks

  validates :first_name, :last_name, :job_role, :user_email, :role, presence: true
  validates :user_email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: "please enter a valid email"}
  validates :user_email, uniqueness: true

  validates :password, presence: true, confirmation: true,
  length: {:within => 6..40}, on: :create
  # validates :password, format: {with: /\A(?=[^\d_].*?\d)\w(\w|[!@#$%])\z/, message: 'Password must include at least one numeric digit.'}

  before_create { generate_token(:auth_token) }

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
