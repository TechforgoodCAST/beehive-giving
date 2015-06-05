class FeedbackController < ApplicationController

  before_filter :load_recipient

  def new
    @redirect_to_funder = params[:redirect_to_funder]
  end

  def create
    @redirect_to_funder = params[:feedback].delete(:redirect_to_funder)
    @feedback = current_user.feedbacks.new(feedback_params)

    respond_to do |format|
      format.html {
        if @feedback.save
          flash[:notice] = "You're a star! Thanks for the feedback."
          redirect_to recipient_comparison_gateway_path(Funder.find_by_slug(@redirect_to_funder))
        else
          render :new
        end
      }
      format.js
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:nps, :taken_away, :informs_decision, :other)
  end

  def load_recipient
    @recipient = current_user.organisation if logged_in?
  end

end
