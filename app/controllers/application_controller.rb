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
    return redirect_to '/', alert: "Please sign in" unless logged_in?
    return ensure_authorised
  end

  def ensure_authorised
    redirect_to unauthorised_path unless current_user.authorised || params[:action] == 'unauthorised'
  end

  def ensure_funder
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless
      current_user.role == 'Funder'
  end

  def ensure_admin
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless
      current_user.role == 'Admin'
  end

  def prevent_funder_access
    redirect_to funder_overview_path(current_user.organisation), alert: "Sorry, you don't have access to that" if current_user.role == 'Funder'
  end

  def check_proposals_ownership
    redirect_to funder_recent_path(current_user.organisation), alert: "Sorry, you don't have access to that" unless
      current_user.organisation == Funder.find_by_slug(params[:id])
  end

  def check_organisation_ownership
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless
      current_user.organisation == Recipient.find_by_slug(params[:id])
  end

  def check_organisation_ownership_or_funder
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless
      logged_in? && current_user.organisation == Recipient.find_by_slug(params[:id]) ||
      logged_in? && current_user.role == 'Funder'
  end

  def check_user_ownership
    redirect_to sign_in_path unless @user == current_user
  end

  def load_feedback
    @feedback = current_user.feedbacks.new
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from StandardError do |exception|
      NewRelic::Agent.add_custom_attributes({ user_id: current_user.id }) if current_user
      NewRelic::Agent.notice_error(exception)
      render "errors/#{status_code}", :status => status_code
    end
  end

  def ensure_profile_for_current_year
    unless current_user.organisation.profiles.where(year: Date.today.year).count > 0
      redirect_to new_recipient_profile_path(current_user.organisation)
    end
  end

  protected

  def status_code
    params[:code] || 500
  end

end
