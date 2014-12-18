class Organisation < ActiveRecord::Base
  validates :name, :contact_name, :contact_role, :contact_email, presence: true
  validates :contact_email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "please enter a valid email"}
  validates :contact_email, uniqueness: true
  validates :slug, uniqueness: true, presence: true

  has_many :profiles

  before_validation :set_slug, unless: :slug

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
end
