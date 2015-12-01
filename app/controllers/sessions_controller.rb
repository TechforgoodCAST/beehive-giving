class SessionsController < ApplicationController

  def new
    redirect_to start_path_for_user(User.find_by_auth_token(cookies[:auth_token])) if cookies[:auth_token]
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
      flash[:error] = 'Incorrect email/password combination, please try again.'
      redirect_to sign_in_path
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_path, notice: 'Signed out!'
  end

  def sign_in_metrics
    current_user.increment!(:sign_in_count)
    current_user.update_attribute(:last_seen, Time.now)
  end

  private

  def start_path_for_user(user)
    if user.role == 'User'
      return signup_organisation_path unless user.organisation
      return new_recipient_profile_path(user.organisation) unless user.organisation.profiles.count > 0
      return edit_recipient_profile_path(user.organisation, user.organisation.profiles.last) unless user.organisation.profiles.last.state == 'complete'
      recommended_funders_path
    else
      funder_dashboard_path
    end
  end

end
