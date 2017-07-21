class FundsController < ApplicationController
  before_action :ensure_logged_in,
                :refine_recommendations # TODO: refactor

  def show
    @fund = Fund.includes(:funder).find_by(slug: params[:id])
    return redirect_to request.referer || root_path, alert: 'Fund not found' unless @fund
    redirect_to account_upgrade_path(@recipient) unless
      @proposal.show_fund?(@fund)
  end

  def index
    @funds = Fund.includes(:funder)
                 .active
                 .order_by(@proposal, params[:sort])
                 .eligibility(@proposal, params[:eligibility])
                 .page(params[:page])
  end

  def recommended # TODO: remove
    @funds = Fund.includes(:funder).find(
      (@proposal.recommended_funds - @proposal.ineligible_fund_ids)
      .take(RECOMMENDATION_LIMIT)
    )
  end

  def eligible # TODO: remove
    @funds = Fund.where(slug: @proposal.eligible_funds.keys)
  end

  def ineligible # TODO: remove
    @funds = Fund.where(slug: @proposal.ineligible_funds.keys)
  end

  def all # TODO: remove
    @funds = @recipient.proposals.last
                       .funds
                       .includes(:funder)
                       .order('recommendations.total_recommendation DESC',
                              'funds.name')
  end

  def tagged
    @tag = params[:tag].tr('-', ' ').capitalize unless params[:tag].blank?
    @funds = Fund.includes(:funder).where('tags ?| array[:tags]', tags: @tag)
    redirect_to root_path, alert: 'Not found' if @funds.empty?
  end

  def sources
    render json: Fund.find_by(slug: params[:id]).sources
  end

  private

    def refine_recommendations # TODO: refactor
      @proposal.refine_recommendations
    end
end
