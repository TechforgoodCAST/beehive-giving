class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  helper_method :logged_in?

  before_action :load_recipient, :load_last_proposal, unless: :error?
  before_action :ensure_signed_up

  rescue_from ActionController::InvalidAuthenticityToken, with: :bad_token
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorised
  rescue_from ActionController::UnknownFormat do
    render 'errors/not_found', status: 404
  end

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

    def user_not_authorised
      flash[:alert] = "Sorry, you don't have access to that"
      redirect_back(fallback_location: root_path)
    end

    def current_user
      return unless cookies[:auth_token]
      @current_user ||= User.includes(:organisation)
                            .find_by(auth_token: cookies[:auth_token])
      session[:user_id] = @current_user.id
      @current_user
    end

    def load_recipient
      return unless logged_in? && current_user.organisation.is_a?(Recipient)
      @recipient = current_user.organisation
    end

    def load_last_proposal
      return unless @recipient
      @proposal = if params[:proposal_id]
                    @recipient.proposals.find_by(id: params[:proposal_id])
                  else
                    @recipient.proposals.last # TODO: remove
                  end
    end

    def funder? # NOTE: legacy support
      current_user.organisation.is_a? Funder
    end

    def ensure_logged_in
      session[:original_url] = request.original_url
      return redirect_to sign_in_path, alert: 'Please sign in' unless logged_in?
    end

    def ensure_signed_up
      return unless logged_in?
      return if public_controller?
      return redirect_funder if funder? # NOTE: legacy support
      redirect start_path unless signed_up?
    end

    def public_controller?
      params[:controller] =~ /admin|articles|pages|sessions|microsites/
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
      cookies.delete(:auth_token)
      redirect sign_in_path, alert: 'Your funders account has been suspended ' \
      'please contact support for more details.'
    end

    def start_path
      return unauthorised_path unless current_user.authorised?
      return new_signup_recipient_path unless @recipient
      return edit_signup_recipient_path(@recipient) unless @recipient.valid? # NOTE: legacy
      return new_signup_proposal_path unless @proposal
      return new_signup_proposal_path if @proposal.initial? # NOTE: legacy
      funds_path(@proposal)
    end

    def ensure_not_signed_up
      redirect_to funds_path(@proposal) if signed_up?
    end
end
