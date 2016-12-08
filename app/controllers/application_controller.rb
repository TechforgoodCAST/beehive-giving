class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :logged_in?
  helper_method :current_user

  before_filter :load_feedback, if: proc { logged_in? }
  before_filter :set_new_relic_user, if: proc { logged_in? }

  rescue_from ActionController::InvalidAuthenticityToken, with: :bad_token

  def bad_token
    flash[:warning] = 'Please sign in.'
    redirect_to '/logout'
  end

  def current_user
    current_user ||= User.includes(:organisation).find_by_auth_token(cookies[:auth_token])
  end

  def set_new_relic_user
    ::NewRelic::Agent.add_custom_attributes({ user_id: current_user.id })
  end

  def logged_in?
    @logged_in ||= (cookies[:auth_token].present? && current_user.present?)
  end

  def ensure_logged_in
    session[:original_url] = request.original_url
    return redirect_to sign_in_path, alert: 'Please sign in' unless logged_in?
    gon.currentUserId = current_user.id
    ensure_authorised
  end

  def load_recipient
    @recipient = current_user.organisation if logged_in?
  end

  def load_proposal
    @proposal = @recipient.proposals.last if logged_in? && @recipient.proposals.count.positive?
  end

  def ensure_authorised
    redirect_to unauthorised_path unless current_user.authorised || params[:action] == 'unauthorised'
  end

  def ensure_recipient
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless
      current_user.role == 'User'
  end

  def ensure_funder
    redirect_to root_path, alert: "Sorry, you don't have access to that" unless
      current_user.role == 'Funder'
  end

  def prevent_funder_access
    redirect_to funder_overview_path(current_user.organisation), alert: "Sorry, you don't have access to that" if current_user.role == 'Funder'
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

  # TODO: refactor
  unless Rails.application.config.consider_all_requests_local
    rescue_from StandardError do |exception|
      NewRelic::Agent.notice_error(exception)
      render "errors/#{status_code}", status: status_code
    end
  end

  def ensure_proposal_present
    return unless current_user.role == 'User'
    if current_user.organisation.proposals.count < 1
      redirect_to new_recipient_proposal_path(current_user.organisation),
                  alert: 'Please create a funding proposal before continuing.'
    elsif current_user.organisation.proposals.last.initial?
      redirect_to edit_recipient_proposal_path(
        current_user.organisation,
        current_user.organisation.proposals.last
      )
    end
  end

  # refactor
  def ensure_profile_for_current_year
    return if current_user.organisation.profiles.where(year: Date.today.year).count.positive?
    redirect_to new_recipient_profile_path(current_user.organisation)
  end

  protected

    def status_code
      params[:code] || 500
    end
end
