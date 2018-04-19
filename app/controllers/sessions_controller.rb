class SessionsController < ApplicationController
  layout 'fullscreen'

  def new
    redirect_to funds_path(@proposal) if logged_in?
  end

  def create # TODO: refactor
    user = User.find_by(email: params[:email].downcase)
    return redirect_to new_password_reset_path if user&.password_digest.nil?
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      sign_in_metrics
      if session[:original_url]
        redirect_to session.delete(:original_url)
      else
        load_recipient
        load_last_proposal
        redirect_to funds_path(@proposal), notice: 'Signed in!'
      end
    else
      flash[:error] = 'Incorrect email/password combination, please try again.'
      redirect_to sign_in_path
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_path, notice: 'Signed out!' # TODO: flash not showing
  end

  private

    def catch_unauthorised; end

    def legacy_funder; end

    def legacy_fundraiser; end

    def registration_incomplete; end

    def registration_invalid; end

    def registration_microsite; end

    def sign_in_metrics
      current_user.increment!(:sign_in_count)
      current_user.update_attribute(:last_seen, Time.zone.now)
    end
end
