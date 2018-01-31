class FundsController < ApplicationController
  before_action :ensure_logged_in, :update_legacy_suitability, except: :sources
  before_action :stub_query, only: %i[index themed]

  def show
    @fund = Fund.includes(:funder).find_by_hashid(params[:id])
    authorize FundContext.new(@fund, @proposal)
    @assessment = Assessment.find_by(fund: @fund, proposal: @proposal)
    render :stub if @fund.stub?
  end

  def index
    @funds = query.page(params[:page])
    @fund_count = query.size # TODO: refactor
    @fund_stubs = @stub_query.order('RANDOM()').limit(5) # TODO: refactor
  end

  def themed
    @theme = Theme.find_by(slug: params[:theme])
    redirect_to root_path, alert: 'Not found' unless @theme
    @funds = themed_query.page(params[:page])
    @fund_count = themed_query.size # TODO: refactor
  end

  def hidden
    @fund = Fund.includes(:funder).find_by_hashid(params[:id])
    @assessment = @proposal.assessments.where(fund: @fund).first
  end

  private

    def user_not_authorised
      if @current_user.subscription_version == 2
        return redirect_to root_path if @fund.nil?
        redirect_to hidden_proposal_fund_path(@proposal, @fund)
      else
        redirect_to account_upgrade_path(@recipient)
      end
    end

    def update_legacy_suitability # TODO: depreceted
      @proposal.update_legacy_suitability
    end

    def query
      Fund.active
          .includes(:funder, :themes, :geo_area)
          .order_by(@proposal, params[:sort])
          .eligibility(@proposal, params[:eligibility])
          .duration(@proposal, params[:duration])
          .select('funds.*', 'assessments.eligibility_status')
    end

    def themed_query
      query.left_joins(:themes).where(themes: { id: @theme })
    end

    def stub_query
      @stub_query = Fund.stubs
                        .includes(:funder)
                        .eligibility(@proposal, 'eligible_noquiz')
    end
end
