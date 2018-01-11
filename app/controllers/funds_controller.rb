class FundsController < ApplicationController
  before_action :ensure_logged_in, :update_legacy_suitability, except: :sources
  before_action :query, :stub_query, only: %i[index themed]

  def show
    @fund = Fund.includes(:funder).find_by_hashid(params[:id])
    authorize FundContext.new(@fund, @proposal)
    render :stub if @fund.stub?
  end

  def index
    query = @query.order_by(@proposal, params[:sort])
    @fund_count = query.size
    @funds = Kaminari.paginate_array(query).page(params[:page])

    @fund_stubs = @stub_query.order("RANDOM()").limit(5)

  end

  def themed
    @theme = Theme.find_by(slug: params[:theme]) if params[:theme].present?
    query = @query.where(themes: { id: @theme })
                  .order_by(@proposal, params[:sort])
    @funds = Kaminari.paginate_array(query).page(params[:page])
    @fund_count = query.size
    redirect_to root_path, alert: 'Not found' if @funds.empty?
  end

  def hidden
    @fund = Fund.includes(:funder).find_by_hashid(params[:id])
  end

  private

    def user_not_authorised
      if @current_user.subscription_version == 2
        redirect_to hidden_proposal_fund_path(@proposal, @fund)
      else
        redirect_to account_upgrade_path(@recipient)
      end
    end

    def update_legacy_suitability # TODO: depreceted
      @proposal.update_legacy_suitability
    end

    def query
      @query = Fund.active
                   .includes(:funder, :themes, :geo_area)
                   .eligibility(@proposal, params[:eligibility])
                   .duration(@proposal, params[:duration])
    end

    def stub_query
      @stub_query = Fund.stubs
                        .includes(:funder)
                        .eligibility(@proposal, 'eligible_noquiz')
    end
end
