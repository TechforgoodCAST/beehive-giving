class SessionsController < ApplicationController
  def new
    redirect_to start_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].downcase)
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
        redirect_to start_path, notice: 'Signed in!'
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

    def sign_in_metrics
      current_user.increment!(:sign_in_count)
      current_user.update_attribute(:last_seen, Time.zone.now)
    end
end
