class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  helper_method :logged_in?

  before_action :load_recipient, :load_last_proposal, unless: :error?

  before_action :catch_unauthorised, if: :logged_in?
  before_action :legacy_funder, if: :logged_in?
  before_action :registration_incomplete, if: :logged_in?
  before_action :registration_invalid, if: :logged_in?
  before_action :registration_microsite, if: :logged_in?

  skip_after_action :intercom_rails_auto_include

  rescue_from ActionController::InvalidAuthenticityToken, with: :bad_token
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorised
  rescue_from ActionController::UnknownFormat do
    render 'errors/not_found', status: 404
  end

  def logged_in?
    current_user != nil
  end

  private

    def bad_token
      redirect_to '/logout', warning: 'Please sign in'
    end

    def catch_unauthorised
      redirect_to unauthorised_path unless current_user.authorised?
    end

    def current_user
      return unless cookies[:auth_token]
      @current_user ||= User.includes(:organisation)
                            .find_by(auth_token: cookies[:auth_token])
      session[:user_id] = @current_user.id
      @current_user
    end

    def ensure_logged_in
      return if logged_in?
      session[:original_url] = request.original_url
      return redirect_to sign_in_path, alert: 'Please sign in'
    end

    def error?
      params[:controller] == 'errors'
    end

    def legacy_funder
      redirect_to legacy_funder_path if current_user.funder?
    end

    # TODO: def legacy_fundraiser

    def load_last_proposal
      return unless @recipient
      @proposal = if params[:proposal_id]
                    @recipient.proposals.find_by(id: params[:proposal_id])
                  else
                     # TODO: remove/refactor
                    if current_user.first_name.nil?
                      @recipient.proposals.last
                    else
                      @recipient.proposals.where.not(state: 'basics').last
                    end
                  end
    end

    def load_recipient
      return unless logged_in? && current_user.organisation.is_a?(Recipient)
      @recipient = current_user.organisation
    end

    def redirect(path, opts = {})
      return unless path
      redirect_to path, opts unless request.path == path
    end

    def registration_incomplete
      redirect(edit_proposal_path(@proposal)) if @proposal&.incomplete?
    end

    def registration_invalid
      redirect(edit_proposal_path(@proposal)) if @proposal&.invalid?
    end

    def registration_microsite
      redirect(edit_proposal_path(@proposal)) if
        current_user&.first_name.nil? && @proposal&.basics?
    end

    def user_not_authorised
      flash[:alert] = "Sorry, you don't have access to that"
      redirect_back(fallback_location: root_path)
    end
end
