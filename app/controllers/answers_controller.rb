class AnswersController < ApplicationController
  def show
    @assessment = Assessment.find_by(id: params[:id])
    @criteria_type = %w[restrictions priorities].select do |i|
      i == params[:criteria_type]
    end[0]

    if @assessment && @criteria_type
      @criteria = @assessment.fund.send(@criteria_type)

      @answers = Answer.where(
        'category_id = ? OR category_id = ?',
        @assessment.recipient_id,
        @assessment.proposal_id
      ).pluck(:criterion_id, :eligible).to_h
    end
  end
end
