class SignupProposalsController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_not_signed_up, only: [:new, :create]
  before_action :load_proposal, only: [:edit, :update] # TODO: refactor

  def new
    if @proposal # NOTE: if invalid legacy proposal
      @proposal.state = 'transferred'
    else
      @proposal = SignupProposal.new(@recipient).build_or_transfer
    end
  end

  def create
    if @proposal # NOTE: if invalid legacy proposal
      @proposal.assign_attributes(proposal_params)
    else
      @proposal = @recipient.proposals.new(proposal_params)
    end
    if @proposal.save
      @proposal.next_step!
      redirect_to recommended_proposal_funds_path(@proposal)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @proposal.update(proposal_params)
      @proposal.next_step!
      flash[:notice] = 'Funding recommendations updated!'
      if session[:return_to]
        redirect_to fund_eligibility_path(session.delete(:return_to))
      else
        redirect_to recommended_proposal_funds_path(@proposal)
      end
    else
      render :edit
    end
  end

  private

    def load_proposal # TODO: refactor
      @proposal = @recipient.proposals.find(params[:id])
    end
end
