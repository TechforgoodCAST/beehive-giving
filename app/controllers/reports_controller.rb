class ReportsController < ApplicationController
  def show
    @proposal = Proposal.find_by(id: params[:proposal_id])
    @collection = @proposal&.collection

    update_report_if_opportunities_changed!

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

  private

    def update_report_if_opportunities_changed!
      return if @proposal.nil? || @collection&.opportunities_last_updated_at.nil?
      return if @proposal.updated_at > @collection.opportunities_last_updated_at

      Assessment.analyse_and_update!(@collection.funds.active, @proposal)
      @proposal.touch
    end
end
