class FeedbackController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient, :prevent_funder_access
  before_filter :redirect_to_funder, only: [:new, :create]

  def new
    @feedback = current_user.feedbacks.new
    @fund = Fund.find_by_slug(@redirect_to_funder) # TODO: refactor

    redirect_to recommended_funds_path, alert: "It looks like you've already provided feedback" if current_user.feedbacks.count > 0
  end

  def create
    @feedback = current_user.feedbacks.new(feedback_params)
    @fund = Fund.find_by_slug(@redirect_to_funder) # TODO: refactor

    if @feedback.save
      session.delete(:redirect_to_funder)
      redirect_to fund_eligibility_path(@fund),
        notice: "You're a star! Thanks for the feedback."
    else
      render :new
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])
    session[:return_to] ||= request.referer
  end

  def update
    @feedback = Feedback.find(params[:id])
    if @feedback.update_attributes(params.require(:feedback).permit(:price))
      flash[:notice] = 'Thanks for the feedback!'
      redirect_to session.delete(:return_to) || recommended_funds_path
    else
      render :edit
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:suitable, :most_useful, :nps, :taken_away,
    :informs_decision, :other, :application_frequency, :grant_frequency,
    :marketing_frequency)
  end

  def redirect_to_funder
    @redirect_to_funder = session[:redirect_to_funder]
  end

end
