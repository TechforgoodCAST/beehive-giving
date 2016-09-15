class EligibilitiesController < ApplicationController

  before_filter :load_recipient, :load_proposal, :load_fund # TODO: refactor

  def new
    # TODO: refactor
    @restrictions = @fund.restrictions.order(:id).uniq
    @eligibility =  1.times { @restrictions.each { |r| @recipient.eligibilities.new(restriction_id: r.id) unless @recipient.eligibilities.where('restriction_id = ?', r.id).count > 0 } }
  end

  def create
    if @recipient.update_attributes(eligibility_params)
      @recipient.unlock_funder!(@fund.funder) if @recipient.locked_funder?(@fund.funder)
      @recipient.check_eligibility(@proposal, @fund)
      render :new
    else
      render :new
    end
  end

  private

    def load_fund
      @fund = Fund.find_by(slug: params[:id])
    end

    def eligibility_params
      params.require(:recipient).permit(eligibilities_attributes: [:id, :eligible, :restriction_id, :recipient_id])
    end

end
