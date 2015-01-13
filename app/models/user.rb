class User < ActiveRecord::Base
  validates :first_name, :last_name, :job_role, :user_email, :role, presence: true
  validates :user_email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: "please enter a valid email"}
  validates :user_email, uniqueness: true

  belongs_to :organisation

  before_create { generate_token(:auth_token) }
  before_create :build_default_organisation

  has_secure_password

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    OrganisationMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  private

  def build_default_organisation
    # build default organisation instance. Will use default params.
    # The foreign key to the owning User model is set automatically
    build_organisation
    true
  end
end
