class ProposalsController < ApplicationController
  before_action :registration_incomplete, except: %i[edit update]
  before_action :registration_invalid, except: %i[edit update]
  before_action :registration_microsite, except: %i[edit update]

  before_action :ensure_logged_in
  before_action :load_country, except: :index
  before_action :load_proposal, only: %i[edit update]

  def new
    authorize Proposal
    @proposal = @recipient.proposals.new(countries: [@country])
  end

  def create
    authorize Proposal
    @proposal = @recipient.proposals.new(proposal_params)

    if @proposal.save
      Assessment.analyse_and_update!(Fund.active, @proposal)
      redirect_to funds_path(@proposal)
    else
      render :new
    end
  end

  def index
    @proposals = @recipient.proposals.where.not(state: 'basics')
  end

  def edit
    return unless request.referer
    session.delete(:return_to) if request.referer.ends_with?('/proposals')
  end

  def update
    if @proposal.update(proposal_params)
      Assessment.analyse_and_update!(Fund.active, @proposal)
      @proposal.complete!

      if session[:return_to]
        fund = Fund.find_by_hashid(session.delete(:return_to))
        redirect_to fund_path(fund, @proposal)
      else
        redirect_to proposals_path
      end
    else
      render :edit
    end
  end

  private

    def load_country
      @country = Country.find_by(alpha2: @recipient.country)
    end

    def load_proposal
      @proposal = @recipient.proposals.find_by(id: params[:id])
      redirect_to proposals_path unless @proposal
    end

    def proposal_params
      params.require(:proposal).permit(
        :affect_geo, :all_funding_required, :funding_duration, :funding_type,
        :private, :public_consent, :tagline, :title, :total_costs,
        district_ids: [], country_ids: [], theme_ids: []
      )
    end

    def user_not_authorised
      redirect_to account_upgrade_path(@recipient)
    end
end
