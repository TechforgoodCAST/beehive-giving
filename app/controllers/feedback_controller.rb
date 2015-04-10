class FeedbackController < ApplicationController

  def create
    @feedback = current_user.feedbacks.new(feedback_params)
    if @feedback.save
      redirect_to :back, notice: "Thanks for your feedback."
    else
      redirect_to :back, alert: "Unable to give feedback, please complete questions 1-3."
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:nps, :taken_away, :informs_decision, :other)
  end

end
