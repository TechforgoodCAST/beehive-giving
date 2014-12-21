class SessionsController < ApplicationController
  def new
  end

  def create
    organisation = Organisation.find_by_contact_email(params[:email])
    if organisation && organisation.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = organisation.auth_token
      else
        cookies[:auth_token] = organisation.auth_token
      end
      redirect_to organisation_path(organisation), notice: 'Logged in!'
    else
      redirect_to login_path, alert: 'Incorrect Email or Password'
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to login_url, notice: 'Logged out!'
  end
end
