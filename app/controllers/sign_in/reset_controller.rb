module SignIn
  class ResetController < ApplicationController
    layout 'fullscreen' # TODO: refactor

    before_action :redirect_if_logged_in, except: :destroy

    def new
      @user = User.find_by(email: session[:email])
      reset_session

      if @user
        send_password_reset(@user)
      else
        redirect_to sign_in_lookup_path
      end
    end

    private

      def send_password_reset(user)
        user.generate_token(:password_reset_token)
        user.password_reset_sent_at = Time.zone.now
        user.save(validate: false)
        # TODO: refactor mailer?
        UserMailer.password_reset(user).deliver_now
      end
  end
end
