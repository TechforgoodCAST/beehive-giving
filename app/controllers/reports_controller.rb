class ReportsController < ApplicationController
  def show
    @proposal = Proposal.find_by(id: params[:proposal_id])
  end
end
