class SessionsController < ApplicationController
  def new
  end

  def create
    organisation = Organisation.find_by_contact_email(params[:email])
    if organisation && organisation.authenticate(params[:password])
      session[:logged_in] = true
      session[:organisation_id] = organisation.id
      redirect_to organisation_path(organisation)
    else
      redirect_to login_path
    end
  end

  def destroy
    session[:logged_in] = nil
    redirect_to login_url
  end
end
