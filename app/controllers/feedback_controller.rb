class FeedbackController < ApplicationController
  before_action :ensure_logged_in
  before_action :redirect_to_funder, only: [:new, :create]

  def new
    @feedback = current_user.feedbacks.new
    @fund = Fund.find_by(slug: @redirect_to_funder) # TODO: refactor

    return unless current_user.feedbacks.count.positive?
    redirect_to recommended_funds_path,
                alert: "It looks like you've already provided feedback"
  end

  def create
    @feedback = current_user.feedbacks.new(feedback_params)
    @fund = Fund.find_by(slug: @redirect_to_funder) # TODO: refactor

    if @feedback.save
      session.delete(:redirect_to_funder)
      redirect_to eligibility_proposal_fund_path(@proposal, @fund),
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

    def redirect_to_funder
      @redirect_to_funder = session[:redirect_to_funder]
    end
end
