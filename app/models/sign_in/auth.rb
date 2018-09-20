module SignIn
  class Auth
    include ActiveModel::Model
    include ActiveModel::SecurePassword

    attr_accessor :password_digest, :remember_me

    has_secure_password

    validates :password, presence: true

    def authenticate(user)
      if valid? && user.authenticate(password)
        true
      else
        errors.add(:password, 'incorrect password')
        false
      end
    end
  end
end
