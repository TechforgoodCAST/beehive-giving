class FeedbackController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient

  def new
    @redirect_to_funder = params[:redirect_to_funder]
    @funder = Funder.find_by_slug(@redirect_to_funder)

    redirect_to funders_path, alert: "It looks like you've already provided feedback" if current_user.feedbacks.count > 0
  end

  def create
    @redirect_to_funder = params[:feedback].delete(:redirect_to_funder)
    @feedback = current_user.feedbacks.new(feedback_params)
    @funder = Funder.find_by_slug(@redirect_to_funder)

    respond_to do |format|
      format.html {
        if @feedback.save
          flash[:notice] = "You're a star! Thanks for the feedback."
          redirect_to recipient_eligibility_path(Funder.find_by_slug(@redirect_to_funder))
        else
          render :new
        end
      }
      format.js
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:nps, :taken_away, :informs_decision, :other, :application_frequency, :grant_frequency, :marketing_frequency)
  end

  def load_recipient
    @recipient = current_user.organisation if logged_in?
  end

end
