class CookiesController < ApplicationController
  def update
    cookies_params.each { |k, v| session[k] = v }
    delete_cookies if should_delete?
    redirect_back(fallback_location: root_path)
  end

  private

    def cookies_params
      params.permit(
        :functional_cookies, :performance_cookies, :read_cookies_notice
      )
    end

    def delete_cookies
      cookies.each do |k, _v|
        next if k =~ /auth_token|_beehive_session/
        cookies.delete(k)
      end
    end

    def should_delete?
      session[:functional_cookies].to_s == 'false' ||
      session[:performance_cookies].to_s == 'false'
    end
end
