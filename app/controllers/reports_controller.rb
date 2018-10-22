class ReportsController < ApplicationController
  def show
    @proposal = Proposal.find_by(id: params[:proposal_id])
    @collection = @proposal&.collection

    if @proposal
      if @proposal.private? && params[:t] != @proposal.access_token
        authenticate_user(@proposal)
      end
    else
      render 'errors/not_found', status: 404
      # TODO: , layout: 'fullscreen'
    end
  end

  def index
    authenticate_user
    return if performed?

    @reports = @current_user.proposals.includes(:collection, :recipient)
                            .order(created_at: :desc)
  end
end
