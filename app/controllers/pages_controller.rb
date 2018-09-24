class PagesController < ApplicationController
  def privacy
    session[:read_cookies_notice] = true if params[:read_cookies_notice]
  end
end
