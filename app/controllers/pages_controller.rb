class PagesController < ApplicationController
  def home
    @proposals = Proposal.includes(:collection).recent_public
  end

  def pricing
    @order = Order.new(
      ENV['STRIPE_AMOUNT_OPPORTUNITY_SEEKER'],
      ENV['STRIPE_FEE_OPPORTUNITY_SEEKER']
    )
  end

  def privacy
    session[:read_cookies_notice] = true if params[:read_cookies_notice]
  end
end
