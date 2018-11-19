class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  helper_method :logged_in?

  before_action :current_user

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

    def authenticate_user(proposal = nil)
      session[:original_url] = request.original_url
      return redirect_to(sign_in_lookup_path) unless logged_in?

      if proposal && (current_user != proposal.user)
        render('errors/forbidden', status: 403)
      end
    end

    def bad_token
      redirect_to '/sign-out', alert: 'Please sign in'
    end

    def current_user
      return unless cookies.encrypted[:auth_token]

      @current_user ||= User.find_by(auth_token: cookies.encrypted[:auth_token])
      session[:user_id] = @current_user.id
      @current_user
    end

    def load_collection
      @collection = Funder.find_by(slug: params[:slug]) ||
                    Theme.find_by(slug: params[:slug])

      render('errors/not_found', status: 404) if @collection.nil?
    end

    def redirect_if_logged_in
      redirect_to reports_path if logged_in?
    end

    def user_not_authorised
      flash[:alert] = "Sorry, you don't have access to that"
      redirect_back(fallback_location: root_path)
    end
end
