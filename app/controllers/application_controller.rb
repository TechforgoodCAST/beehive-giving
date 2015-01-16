class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # force_ssl

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def ensure_logged_in
    if current_user.nil?
      redirect_to "/"
      false
    else
      true
    end
  end

  def check_user_ownership
    redirect_to login_path unless @user == current_user
  end
end
