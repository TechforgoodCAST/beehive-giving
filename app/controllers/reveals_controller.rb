class RevealsController < ApplicationController
  before_action :ensure_logged_in

  def create
    authorize :reveal
    assessment = Assessment.find(params[:assessment])
    assessment.update(revealed: true)
    @recipient.reveals << assessment.fund.slug
    @recipient.save
    redirect_to fund_path(assessment.fund, @proposal)
  end

  private

    def user_not_authorised
      redirect_to account_upgrade_path(@recipient)
    end
end
