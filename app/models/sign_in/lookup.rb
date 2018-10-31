module SignIn
  class Lookup
    include ActiveModel::Model
    include EmailFormatValidations

    attr_accessor :email
    attr_reader :user

    validate :lookup_user

    private

      def lookup_user
        @user = User.find_by(email: email)
        msg = 'No account found, please ' \
              '<a href="/">create your first report</a>'.html_safe
        errors.add(:email, msg) unless @user
      end
  end
end
