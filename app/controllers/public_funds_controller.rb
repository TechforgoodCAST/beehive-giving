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

  def themed
    @theme = Theme.find_by(slug: params[:theme]) if params[:theme].present?
    @funds = Fund.active
                 .includes(:funder, :themes)
                 .where(themes: { id: @theme })
                 .page(params[:page])
    redirect_to public_funds_path, alert: 'Not found' if @funds.empty?
  end

  private

    def ensure_logged_out
      redirect_to root_path if logged_in?
    end

    def public_fund?(slug)
      Fund.active.recent.limit(3).pluck(:slug).include?(slug)
    end
end
