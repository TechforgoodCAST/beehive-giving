module SignIn
  class Set
    include ActiveModel::Model
    include ActiveModel::SecurePassword

    attr_accessor :password_digest, :user

    has_secure_password

    validates :password, length: { minimum: 6 }, format: {
      with: /\A(?=.*\d)(?=.*[a-zA-Z]).*\z/,
      message: 'must contain at least one number'
    }
    validates :password_confirmation, presence: true

    def save
      valid? && update_user
    end

    private

      def update_user
        @user&.update(
          password: password,
          password_confirmation: password_confirmation
        )
      end
  end
end
