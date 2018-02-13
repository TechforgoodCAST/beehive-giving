class RevealsController < ApplicationController
  before_action :ensure_logged_in

  def create
    authorize :reveal
    fund = Fund.find_by_hashid(params[:fund])
    @recipient.reveals << fund.slug
    @recipient.save
    redirect_to fund_path(fund, @proposal)
  end

  private

    def user_not_authorised
      redirect_to account_upgrade_path(@recipient)
    end
end
