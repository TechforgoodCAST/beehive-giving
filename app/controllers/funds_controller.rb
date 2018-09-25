class FundsController < ApplicationController
  before_action :update_legacy_suitability, except: :sources
  before_action :load_fund, only: %i[hidden show]
  before_action :stub_assessment, only: %i[hidden show]

  def show
    authorize FundContext.new(@fund, @proposal)
    @assessment = Assessment.find_by(fund: @fund, proposal: @proposal)
  end

  def index
    query = Fund.filter_sort(@proposal, params)
    @funds = query.page(params[:page])
    update_analysis(query) if @proposal
  end

  def themed
    @theme = Theme.find_by(slug: params[:theme])
    redirect_to funds_path(@proposal), alert: 'Not found' unless @theme

    query = Fund.filter_sort(@proposal, params)
                .left_joins(:themes).where(themes: { id: @theme })

    @funds = query.page(params[:page])
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

    def load_fund
      @fund = Fund.includes(:funder)
                  .where("state = 'active' OR state = 'stub'")
                  .find_by_hashid(params[:id])
    end

    def stub_assessment
      @stub_assessment = OpenStruct.new(fund: @fund, proposal: @proposal)
    end
end
