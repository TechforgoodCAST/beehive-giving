class FundsController < ApplicationController
  before_action :ensure_logged_in, :ensure_proposal_present,
                :refine_recommendations

  def show
    @fund = Fund.includes(:funder).find_by(slug: params[:id])
  end

  def recommended
    @funds = Fund.includes(:funder).find(
      (@proposal.recommended_funds - @proposal.ineligible_funds)
      .take(Recipient::RECOMMENDATION_LIMIT) # TODO: move constant
    )
  end

  def eligible
    @funds = @recipient.eligible_funds
  end

  def ineligible
    @funds = @recipient.ineligible_funds
  end

  def all
    @funds = @recipient.proposals.last
                       .funds
                       .includes(:funder)
                       .order('recommendations.total_recommendation DESC',
                              'funds.name')
  end

  def tagged
    @tag = params[:tag].tr('-', ' ').capitalize
    @funds = Fund.includes(:funder).where('tags ?| array[:tags]', tags: @tag)
    redirect_to root_path, alert: 'Not found' if @funds.empty?
  end

  private

    def refine_recommendations # TODO: refactor
      @proposal.refine_recommendations
    end
end
