class PublicFundsController < ApplicationController
  before_action :ensure_logged_out

  def index
    @funds = Fund.active.recent.includes(:funder).page(params[:page])
  end

  def show
    return redirect_to public_funds_path unless public_fund?(params[:slug])
    @fund = Fund.find_by(slug: params[:slug])
    return redirect_to public_funds_path unless @fund
    @restrictions = @fund.restrictions.pluck(:category, :details)
  end

  private

    def ensure_logged_out
      redirect_to root_path if logged_in?
    end

    def public_fund?(slug)
      Fund.active.recent.limit(3).pluck(:slug).include?(slug)
    end
end
