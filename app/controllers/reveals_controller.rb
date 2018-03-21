class RevealsController < ApplicationController
  include ::RevealsTracker

  before_action :ensure_logged_in

  def create
    authorize :reveal
    assessment = Assessment.find(params[:assessment])
    update_assessment(assessment)
    track(assessment)
    redirect_to fund_path(assessment.fund, @proposal)
  end

  private

    def track(assessment)
      mixpanel_track(
        @current_user,
        request,
        fund_slug: assessment.fund.slug,
        proposal_id: assessment.proposal.id
      )
    end

    def update_assessment(assessment)
      assessment.update(revealed: true)
      @recipient.reveals << assessment.fund.slug
      @recipient.save
    end

    def user_not_authorised
      redirect_to account_upgrade_path(@recipient)
    end
end
