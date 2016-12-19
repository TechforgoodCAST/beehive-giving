class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  before_action :load_recipient, :load_last_proposal, unless: :error?
  # TODO: before_action :load_feedback, if: proc { logged_in? }
  # TODO: before_action :set_new_relic_user, if: proc { logged_in? }

  unless Rails.application.config.consider_all_requests_local
    rescue_from StandardError do
      render "errors/#{status_code}", status: status_code
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken, with: :bad_token

  def current_user
    return unless cookies[:auth_token]
    @current_user ||= User.includes(:organisation)
                          .find_by(auth_token: cookies[:auth_token])
  end

  def logged_in?
    current_user != nil
  end

  def ensure_logged_in
    session[:original_url] = request.original_url
    return redirect_to sign_in_path, alert: 'Please sign in' unless logged_in?
    gon.currentUserId = current_user.id
    ensure_authorised
    ensure_user
  end

  def load_recipient
    @recipient = current_user.organisation if logged_in?
  end

  def load_last_proposal
    return unless @recipient && logged_in?
    @proposal = Proposal.order(:created_at).find_by(recipient_id: @recipient.id)
  end

  def ensure_proposal_present
    ensure_user
    if !@proposal
      redirect_to new_recipient_proposal_path(@recipient),
                  alert: 'Please create a funding proposal before continuing.'
    elsif @proposal.initial?
      redirect_to edit_recipient_proposal_path(@recipient, @proposal)
    end
  end

  def ensure_funder # TODO: deprecated
    return if logged_in? && current_user.role == 'Funder'
    redirect_to sign_in_path, alert: "Sorry, you don't have access to that"
  end

  # TODO: def check_organisation_ownership
  #   redirect_to root_path, alert: "Sorry, you don't have access to that" unless
  #     current_user.organisation == Recipient.find_by(slug: params[:id])
  # end

  # TODO: def check_user_ownership
  #   redirect_to sign_in_path unless @user == current_user
  # end

  # TODO: def load_feedback
  #   @feedback = current_user.feedbacks.new
  # end

  private

    def error?
      params[:controller] == 'errors'
    end

    def bad_token
      redirect_to '/logout', warning: 'Please sign in'
    end

    def ensure_authorised
      redirect_to unauthorised_path unless
        current_user.authorised || params[:action] == 'unauthorised'
    end

    def ensure_user
      return if current_user.role == 'User'
      redirect_to root_path, alert: "Sorry, you don't have access to that"
    end
end
