class ProposalsController < ApplicationController
  before_action :ensure_logged_in
  before_action :load_proposal, only: [:edit, :update] # TODO: refactor

  def new
    return redirect_to edit_signup_proposal_path(@proposal) unless
      @proposal.complete?

    authorize Proposal
    @proposal = @recipient.proposals.new(
      countries: [Country.find_by(alpha2: @recipient.country)]
    )
  end

  def create
    @proposal = @recipient.proposals.new(
      proposal_params.merge(state: 'registered')
    )
    if @proposal.save
      Assessment.analyse_and_update!(Fund.active, @proposal)
      @proposal.next_step!
      redirect_to funds_path(@proposal)
    else
      render :new
    end
  end

  def index
    @proposals = @recipient.proposals.order_by(params[:sort])
  end

  def edit
    return unless request.referer
    session.delete(:return_to) if request.referer.ends_with?('/proposals')
  end

  def update
    @proposal.state = 'transferred' if @proposal.initial?
    respond_to do |format|
      if @proposal.update_attributes(proposal_params)
        Assessment.analyse_and_update!(Fund.active, @proposal)
        @proposal.next_step! unless @proposal.complete?
        flash[:notice] = 'Funding recommendations updated!'
        fund = Fund.find_by_hashid(session.delete(:return_to))
        format.js do
          if session[:return_to]
            render js: "window.location.href = '#{fund_path(fund, @proposal)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          else
            render js: "window.location.href = '#{funds_path(@proposal)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          end
        end
        format.html do
          if session[:return_to]
            redirect_to fund_path(fund, @proposal)
          else
            redirect_to funds_path(@proposal)
          end
        end
      else
        format.js
        format.html { render :edit }
      end
    end
  end

  private

    def user_not_authorised
      redirect_to account_upgrade_path(@recipient)
    end

    def load_proposal # TODO: refactor
      @proposal = @recipient.proposals.find(params[:id])
    end
end
