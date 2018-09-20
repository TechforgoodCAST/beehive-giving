module SignIn
  class LookupController < ApplicationController
    layout 'fullscreen' # TODO: refactor

    before_action :redirect_if_logged_in

    def new
      @form = SignIn::Lookup.new
    end

    def create
      @form = SignIn::Lookup.new(form_params)

      if @form.valid? && @form.user
        session[:email] = form_params[:email]
        redirect_to_path
      else
        reset_session
        render :new
      end
    end

    private

      def form_params
        params.require(:sign_in_lookup).permit(:email)
      end

      def redirect_to_path
        if @form.user.password_digest.present?
          redirect_to sign_in_auth_path
        else
          redirect_to sign_in_reset_path
        end
      end
  end
end
