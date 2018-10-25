module SignIn
  class SetController < ApplicationController
    layout 'fullscreen' # TODO: refactor

    before_action :redirect_if_logged_in, :load_user

    def new
      if @user && @user.password_reset_sent_at > 1.hour.ago
        @form = SignIn::Set.new(user: @user)
      else
        reset_session
        msg = 'Password reset expired, please request a new one.'
        redirect_to sign_in_lookup_path, alert: msg
      end
    end

    def create
      @form = SignIn::Set.new(form_params.merge(user: @user))

      if @form.save
        reset_session
        cookies.encrypted[:auth_token] = @user.auth_token
        redirect_to reports_path, notice: 'Password updated'
      else
        render :new
      end
    end

    private

      def form_params
        params.require(:sign_in_set).permit(
          :password, :password_confirmation, :marketing_consent, :terms_agreed
        )
      end

      def load_user
        @user = User.find_by(password_reset_token: params[:token])
      end
  end
end
