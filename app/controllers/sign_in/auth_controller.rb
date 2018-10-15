module SignIn
  class AuthController < ApplicationController
    before_action :redirect_if_logged_in, except: :destroy

    def new
      @user = User.find_by(email: session[:email])

      if @user.nil?
        reset_session
        redirect_to sign_in_lookup_path
      elsif @user.password_digest.nil?
        redirect_to sign_in_reset_path
      end

      @form = SignIn::Auth.new
    end

    def create
      @user = User.find_by(email: session[:email])
      @form = SignIn::Auth.new(form_params)

      if @form.authenticate(@user)
        original_url = session[:original_url]
        reset_session
        sign_in
        update_sign_in_metrics
        redirect_to(original_url || reports_path) # TODO: test
      else
        render :new
      end
    end

    def destroy
      reset_session
      cookies.delete(:auth_token)
      redirect_to root_path, notice: 'Signed out!' # TODO: flash not showing
    end

    private

      def form_params
        params.require(:sign_in_auth).permit(:password, :remember_me)
      end

      def sign_in
        if ActiveModel::Type::Boolean.new.cast(form_params[:remember_me])
          cookies.permanent.encrypted[:auth_token] = @user.auth_token
        else
          cookies.encrypted[:auth_token] = @user.auth_token
        end
      end

      def update_sign_in_metrics
        @user.increment!(:sign_in_count)
        @user.update_attribute(:last_seen, Time.zone.now)
      end
  end
end
