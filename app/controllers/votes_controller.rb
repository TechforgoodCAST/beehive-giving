class VotesController < ApplicationController
  before_action :load_assessment

  def new
    if @assessment
      @vote = @assessment.votes.new
    else
      redirect_back(fallback_location: opportunities_path)
    end
  end

  def create
    @vote = @assessment.votes.new(form_params)

    if @vote.save
      redirect_to(
        report_path(@assessment.proposal, anchor: "assessment-#{@assessment.id}"),
        notice: "Successfully voted on assessment ##{@assessment.id}"
      )
    else
      render :new
    end
  end

  private

    def form_params
      params.require(:vote).permit(
        :relationship_to_assessment, :relationship_details, :agree_with_rating,
        :reason
      )
    end

    def load_assessment
      @assessment = Assessment.find_by(id: params[:id])
    end
end
