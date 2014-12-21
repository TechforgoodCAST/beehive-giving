class Organisation < ActiveRecord::Base
  validates :name, :contact_name, :contact_role, :contact_email, presence: true
  validates :contact_email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "please enter a valid email"}
  validates :contact_email, uniqueness: true
  validates :slug, uniqueness: true, presence: true

  has_many :profiles

  before_validation :set_slug, unless: :slug
  before_create { generate_token(:auth_token) }

  has_secure_password

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

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    OrganisationMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Organisation.exists?(column => self[column])
  end
end
