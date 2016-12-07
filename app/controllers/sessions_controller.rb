class SessionsController < ApplicationController

  def new
    redirect_to start_path_for_user(current_user) if current_user
  end

  def check
    if logged_in?
      redirect_to start_path_for_user(current_user)
    else
      redirect_to signup_user_path
    end
  end

  def create
    user = User.find_by_user_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
        sign_in_metrics
      else
        cookies[:auth_token] = user.auth_token
        sign_in_metrics
      end
      if session[:original_url]
        redirect_to session.delete(:original_url)
      else
        redirect_to start_path_for_user(user), notice: 'Signed in!'
      end
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
        return new_recipient_proposal_path(user.organisation) unless user.organisation.proposals.count.positive?
        recommended_funds_path
      else
        funder_overview_path(user.organisation)
      end
    end

end
