class EnquiriesController < ApplicationController
  before_action :ensure_logged_in
  before_action :load_fund # TODO: refactor
  before_action :authenticate

  def create
    @enquiry = Enquiry.where(
      proposal: @proposal,
      fund: @fund
    ).first_or_create.increment!(:approach_funder_count)

    redirect_to @fund.application_link, target: '_blank'
  end

  private

    def load_fund # TODO: refactor to applicaiton controller?
      @fund = Fund.includes(:funder).find_by_hashid(params[:id])
    end

    def authenticate
      authorize EnquiryContext.new(@fund, @proposal)
    end

    def user_not_authorised
      if @current_user.subscription_version == 2
        redirect_to account_upgrade_path(@recipient)
      else
        redirect_to proposal_fund_path(@proposal, @fund)
      end
    end
end
