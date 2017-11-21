class RevealsController < ApplicationController
  before_action :ensure_logged_in

  def create
    authorize :request
    fund = Fund.find_by_hashid(params[:fund])
    @request = Request.new(fund: fund, recipient: @recipient, message: @params[:message])
    @request.save
    redirect_to proposal_fund_path(@proposal, fund)
  end

  private

    def user_not_authorised
      redirect_to account_upgrade_path(@recipient)
    end
end
