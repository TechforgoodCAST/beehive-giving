class PagesController < ApplicationController
  def home
    @proposals = Proposal.includes(:collection).recent_public
  end

  def privacy
    session[:read_cookies_notice] = true if params[:read_cookies_notice]
  end
end
