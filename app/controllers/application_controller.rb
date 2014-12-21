class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  force_ssl

  def logged_in?
    session[:logged_in]
  end
  helper_method :logged_in?

  def current_organisation
    return nil unless logged_in?
    @current_organisation ||= Organisation.find(session[:organisation_id])
  end

  def check_organisation_ownership
    redirect_to login_path unless @organisation == current_organisation
  end
end
