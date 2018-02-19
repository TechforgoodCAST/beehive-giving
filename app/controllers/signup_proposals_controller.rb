class SignupProposalsController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_not_signed_up, only: [:new, :create]
  before_action :load_proposal, only: [:edit, :update] # TODO: refactor

  def new
    if @proposal # NOTE: if invalid legacy proposal
      @proposal.state = 'transferred'
    else
      @proposal = @recipient.proposals.new(
        # TODO: avoid db call
        countries: [Country.find_by(alpha2: @recipient.country)]
      )
    end
  end

  def create
    if @proposal # NOTE: if invalid legacy proposal
      @proposal.assign_attributes(proposal_params)
    else
      @proposal = @recipient.proposals.new(proposal_params)
    end
    if @proposal.save
      Assessment.analyse_and_update!(Fund.active, @proposal)
      @proposal.next_step!
      redirect_to funds_path(@proposal)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @proposal.update(proposal_params)
      @proposal.next_step!
      flash[:notice] = 'Funding recommendations updated!'
      redirect_to return_to_path
    else
      render :edit
    end
  end

  private

    def return_to_path
      if session[:return_to]
        fund_path(session.delete(:return_to), @proposal)
      else
        funds_path(@proposal)
      end
    end

    def load_proposal # TODO: refactor
      @proposal = @recipient.proposals.find(params[:id])
    end
end
