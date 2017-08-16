class FundsController < ApplicationController
  before_action :ensure_logged_in, :update_legacy_suitability

  def show
    @fund = Fund.includes(:funder).find_by(slug: params[:id])
    return redirect_to request.referer || root_path, alert: 'Fund not found' unless @fund
    redirect_to account_upgrade_path(@recipient) unless
      @proposal.show_fund?(@fund)
  end

  def index
    query = Fund.includes(:funder)
                .active
                .eligibility(@proposal, params[:eligibility])
                .max_duration(@proposal, params[:duration])
                .min_duration(@proposal, params[:duration])
                .order_by(@proposal, params[:sort])

    @fund_count = query.count
    @funds = Kaminari.paginate_array(query).page(params[:page])
  end

  def tagged
    @tag = params[:tag].tr('-', ' ').capitalize if params[:tag].present?
    @funds = Fund.includes(:funder).where('tags ?| array[:tags]', tags: @tag)
    redirect_to root_path, alert: 'Not found' if @funds.empty?
  end

  def sources
    render json: Fund.find_by(slug: params[:id]).sources
  end

  private

    def update_legacy_suitability
      @proposal.update_legacy_suitability
    end
end
