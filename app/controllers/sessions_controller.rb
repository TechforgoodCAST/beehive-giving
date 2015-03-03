class SessionsController < ApplicationController
  def new
  end

  def check
    if logged_in?
      redirect_to start_path_for_user(current_user)
    else
      redirect_to signup_user_path
    end
  end

  def create
    user = User.find_by_user_email(params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
        sign_in_metrics
      else
        cookies[:auth_token] = user.auth_token
        sign_in_metrics
      end
      redirect_to start_path_for_user(user), notice: 'Signed in!'
    else
      redirect_to root_path, alert: 'Incorrect Email or Password'
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_path, notice: 'Signed out!'
  end

  def sign_in_metrics
    current_user.increment(:sign_in_count)
    current_user.update_attribute(:last_seen, Time.now)
  end

  private

  def start_path_for_user(user)
    if user.role == 'User'
      return signup_organisation_path unless user.organisation_id
      return signup_profile_path unless user.organisation.profiles.any?
      return signup_comparison_path if user.organisation.profiles.count == 1
      organisation_path(current_user.organisation)
    else
      funder_path(current_user.organisation)
    end
  end
end
