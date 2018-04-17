class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  helper_method :logged_in?

  before_action :load_recipient, :load_last_proposal, unless: :error?
  before_action :legacy_funder, :legacy_fundraiser, if: :logged_in?
  before_action :catch_unauthorised, if: :logged_in?

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

    def ensure_logged_in
      return if logged_in?
      session[:original_url] = request.original_url
      return redirect_to sign_in_path, alert: 'Please sign in'
    end

    def redirect(path, opts = {})
      return unless path
      redirect_to path, opts unless request.path == path
    end

    def legacy_funder
      redirect_to legacy_funder_path if current_user.funder?
    end

    def legacy_fundraiser
      redirect_to legacy_fundraiser_path if current_user.legacy?
    end

    def catch_unauthorised
      redirect_to unauthorised_path unless current_user.authorised?
    end
end
