class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :logged_in?
  helper_method :current_user

  before_filter :load_feedback, :if => Proc.new { logged_in? }

  def current_user
    current_user ||= User.find_by_auth_token(cookies[:auth_token])
  end

  def logged_in?
    @logged_in ||= (cookies[:auth_token].present? and current_user.present?)
  end

  def ensure_logged_in
    redirect_to "/" unless logged_in?
  end

  def ensure_funder
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless current_user.role == 'Funder'
  end

  def check_organisation_ownership
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless current_user.organisation_id == @organisation.id
  end

  def check_user_ownership
    redirect_to login_path unless @user == current_user
  end

  def load_feedback
    @feedback = current_user.feedbacks.new
  end

end
