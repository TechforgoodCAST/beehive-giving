class ProposalsController < ApplicationController
  before_action :ensure_logged_in
  before_action :load_proposal, only: [:edit, :update]

  def new
    if @proposal.complete?
      @proposal = @recipient.proposals.new(
        countries: [Country.find_by(alpha2: @recipient.country)]
      )
      return if @recipient.subscribed?
      redirect_to request.referer || root_path,
                  alert: 'Please upgrade to create multiple funding proposals'
      # TODO: redirect to update path
    else
      redirect_to edit_signup_proposal_path(@proposal)
    end
  end

  def create
    @proposal = @recipient.proposals.new(
      proposal_params.merge(state: 'registered')
    )
    if @proposal.save
      @proposal.next_step!
      redirect_to recommended_funds_path
    else
      render :new
    end
  end

  def index
    if @proposal
      @proposals = @recipient.proposals
    else
      redirect_to recommended_funds_path
    end
  end

  def edit
    return unless request.referer
    session.delete(:return_to) if request.referer.ends_with?('/proposals')
  end

  def update
    @proposal.state = 'transferred' if @proposal.initial?
    respond_to do |format|
      if @proposal.update_attributes(proposal_params)
        format.js do
          @proposal.next_step! unless @proposal.complete?
          flash[:notice] = 'Funding recommendations updated!'

          if session[:return_to]
            fund = Fund.find_by(slug: session.delete(:return_to))
            render js: "window.location.href = '#{fund_eligibility_path(fund)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          else
            render js: "window.location.href = '#{recommended_funds_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          end
        end
        format.html do
          @proposal.next_step! unless @proposal.complete?
          flash[:notice] = 'Funding recommendations updated!'

          if session[:return_to]
            fund = Fund.find_by(slug: session.delete(:return_to))
            redirect_to fund_eligibility_path(fund)
          else
            redirect_to recommended_funds_path
          end
        end
      else
        format.js
        format.html { render :edit }
      end
    end
  end

  private

    def load_proposal
      @proposal = Proposal.find(params[:id])
    end
end
