class EnquiriesController < ApplicationController # TODO: ApplicationsController?
  before_filter :ensure_logged_in, :ensure_recipient # TODO:
  before_filter :load_recipient, :load_fund, :ensure_proposal_present, :load_proposal # TODO: refactor

  def new
    if @proposal.eligible?(@fund) && @recipient.proposals?
      render :new
    elsif !@recipient.proposals?
      redirect_to new_recipient_proposal_path(@recipient, return_to: @fund),
        alert: 'Please provide details of your funding request before applying.'
    else
      redirect_to fund_eligibility_path(@fund),
        alert: 'You need to check your eligibility before applying.'
    end
  end

  def create
    @enquiry = Enquiry.where(
      proposal: @proposal,
      fund: @fund
    ).first_or_create.increment!(:approach_funder_count)

    redirect_to @fund.application_link, target: '_blank'
  end

  private

    def load_fund # TODO: refactor to applicaiton controller?
      @fund = Fund.includes(:funder).find_by(slug: params[:id])
    end
end
