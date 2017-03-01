class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :logged_in?

  before_action :load_recipient, :load_last_proposal, unless: :error?
  before_action :ensure_signed_up

  rescue_from ActionController::InvalidAuthenticityToken, with: :bad_token

  def logged_in?
    current_user != nil
  end

  private

    include StrongParameters

    def error?
      params[:controller] == 'errors'
    end

    def bad_token
      redirect_to '/logout', warning: 'Please sign in'
    end

    def current_user
      return unless cookies[:auth_token]
      @current_user ||= User.includes(:organisation)
                            .find_by(auth_token: cookies[:auth_token])
    end

    def load_recipient
      return unless logged_in?
      @recipient = current_user.organisation
    end

    def load_last_proposal
      return unless @recipient
      return if funder? # NOTE: legacy support
      @proposal = @recipient.proposals.last
    end

    def funder? # NOTE: legacy support
      current_user.role == 'Funder'
    end

    def ensure_logged_in
      session[:original_url] = request.original_url
      return redirect_to sign_in_path, alert: 'Please sign in' unless logged_in?
    end

    def ensure_signed_up
      return unless logged_in?
      return if params[:controller] =~ /admin|funders|pages|sessions/
      return redirect_funder if funder? # NOTE: legacy support
      redirect start_path unless signed_up?
    end

    def signed_up?
      current_user.authorised? &&
        (@proposal && !@proposal.initial?) # NOTE: legacy support
    end

    def redirect(path, opts = {})
      return unless path
      redirect_to path, opts unless request.path == path
    end

    def redirect_funder # NOTE: legacy support
      redirect funder_overview_path(current_user.organisation),
               alert: "Sorry, you don't have access to that"
    end

    def start_path
      return unauthorised_path               unless current_user.authorised?
      return signup_organisation_path        unless @recipient
      return edit_recipient_path(@recipient) unless @recipient.valid? # legacy
      return new_signup_proposal_path        unless @proposal
      return new_signup_proposal_path        if @proposal.initial?    # legacy
      recommended_funds_path
    end

    def ensure_not_signed_up
      redirect_to recommended_funds_path if signed_up?
    end
end
