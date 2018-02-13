class FundsController < ApplicationController
  before_action :update_legacy_suitability, except: :sources
  before_action :load_fund, only: %i[hidden show]

  def show
    authorize FundContext.new(@fund, @proposal)
    @assessment = Assessment.find_by(fund: @fund, proposal: @proposal)
    render :stub if @fund.stub?
  end

  def index
    update_analysis(query) if @proposal
    @funds = query.page(params[:page])
    # TODO: refactor
    @fund_count = query.size
    @fund_stubs = Fund.stubs.includes(:funder).order('RANDOM()').limit(5)
    # TODO: end
  end

  def themed
    @theme = Theme.find_by(slug: params[:theme])
    redirect_to funds_path(@proposal), alert: 'Not found' unless @theme
    @funds = themed_query.page(params[:page])
    @fund_count = themed_query.size # TODO: refactor
  end

  def hidden
    return redirect_to root_path unless @fund
    @assessment = @proposal.assessments.where(fund: @fund).first if @proposal
  end

  private

    def user_not_authorised
      return redirect_to funds_path(@proposal) if @fund.nil?
      redirect_to hidden_path(@fund, @proposal)
    end

    def update_analysis(funds)
      unassessed = funds.where(
        "assessments.fund_version != #{Fund.version} OR " \
        'assessments.fund_version IS NULL'
      )
      return if unassessed.empty?
      Assessment.analyse_and_update!(unassessed, @proposal)
    end

    def update_legacy_suitability # TODO: depreceted
      @proposal&.update_legacy_suitability
    end

    def query
      # TODO: refactor into class method?
      Fund.join(@proposal)
          .includes(:funder, :themes, :geo_area)
          .order_by(params[:sort])
          .eligibility(params[:eligibility])
          .duration(@proposal, params[:duration])
          .active
          .select('funds.*', 'assessments.eligibility_status')
    end

    def themed_query
      query.left_joins(:themes).where(themes: { id: @theme })
    end

    def load_fund
      @fund = Fund.includes(:funder)
                  .where("state = 'active' OR state = 'stub'")
                  .find_by_hashid(params[:id])
    end
end
