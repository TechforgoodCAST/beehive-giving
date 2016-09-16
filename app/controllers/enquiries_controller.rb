class EnquiriesController < ApplicationController # TODO: ApplicationsController?

  before_filter :ensure_logged_in # TODO:
  before_filter :load_recipient, :load_proposal, :load_fund # TODO: refactor

  def new
    if @proposal.eligible?(@fund) && @recipient.has_proposal?
      render :new
    elsif !@recipient.has_proposal?
      redirect_to new_recipient_proposal_path(@recipient, return_to: @fund),
        alert: 'Please provide details of your funding request before applying.'
    else
      redirect_to fund_eligibility_path(@fund),
        alert: 'You need to check your eligibility before applying.'
    end
  end

  def create
    @recommendation = Recommendation.where(recipient: @recipient, funder: @funder).first
    @funder_attribute = @funder.attributes.order(created_at: :desc).where('funding_stream = ? OR funding_stream = ?', params[:funding_stream], 'All').first

    @enquiry = Enquiry.where(recipient: @recipient, funder: @funder, funding_stream: params[:funding_stream]).first_or_create
    @enquiry.increment!(:approach_funder_count)
    @enquiry.update_attributes(funding_stream: params[:funding_stream])

    redirect_to "http://#{@funder_attribute.application_link}", target: '_blank'
  end

  private

    def load_fund # TODO: refactor to applicaiton controller?
      @fund = Fund.find_by(slug: params[:id])
    end

end
