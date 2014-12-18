class Organisation < ActiveRecord::Base
  validates :name, :contact_name, :contact_role, :contact_email, presence: true
  validates :contact_email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "please enter a valid email"}
  validates :contact_email, uniqueness: true

  has_many :profiles
end
