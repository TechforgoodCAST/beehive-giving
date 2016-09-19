class EligibilitiesController < ApplicationController

  before_filter :ensure_logged_in # TODO:
  before_filter :load_recipient, :load_proposal, :load_fund # TODO: refactor

  def new
    @criteria = []
    @fund.restrictions.order(:id).uniq.each do |r|
      @criteria << @recipient.eligibilities.where(restriction: r).first_or_initialize
    end

    if @recipient.incomplete_first_proposal?
      session[:return_to] = @fund.slug
      redirect_to edit_recipient_proposal_path(@recipient, @recipient.proposals.last)
    elsif current_user.feedbacks.count < 1 && (@recipient.locked_fund?(@fund) && @recipient.funds_checked == 2)
      session[:redirect_to_funder] = @fund.slug
      redirect_to new_feedback_path
    elsif @recipient.funds_checked < 3
      render :new
    else
      # TODO: refactor redirect to upgrade path
      redirect_to edit_feedback_path(current_user.feedbacks.last)
    end
  end

  def create
    if @recipient.update_attributes(eligibility_params)
      @recipient.increment!(:funds_checked) if @proposal.recommendation(@fund).eligibility == nil # TODO: refactor
      @recipient.check_eligibility(@proposal, @fund)
      render :new
    else
      render :new
    end
  end

  private

    def load_fund # TODO: refactor to applicaiton controller?
      @fund = Fund.find_by(slug: params[:id])
    end

    def eligibility_params
      params.require(:recipient).permit(eligibilities_attributes: [:id, :eligible, :restriction_id, :recipient_id])
    end

end
