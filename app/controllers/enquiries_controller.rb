class EnquiriesController < ApplicationController
  before_action :ensure_logged_in
  before_action :load_fund # TODO: refactor

  def new
    if @proposal && @proposal.eligible?(@fund.slug)
      render :new
    elsif !@proposal
      redirect_to new_recipient_proposal_path(@recipient, return_to: @fund),
                  alert: 'Please provide details of your funding request ' \
                         'before applying.'
    else
      redirect_to proposal_fund_path(@proposal, @fund),
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
