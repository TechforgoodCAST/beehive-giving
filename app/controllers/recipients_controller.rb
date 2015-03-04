class RecipientsController < ApplicationController
  before_filter :ensure_logged_in
  # before_filter :ensure_funder
  before_filter :load_current_organisation

  def show
    @recipient = Recipient.find_by_slug(params[:id])
    @grants = @recipient.grants
    @funder = current_user.organisation
  end

  def dashboard
    @funders = Funder.all
    @feedback = current_user.feedbacks.new
  end

  def gateway
    @funder    = Funder.find_by_slug(params[:id])
    @recipient = @current_organisation
    @feedback  = current_user.feedbacks.new
  end

  def comparison
    @funder = Funder.find_by_slug(params[:id])
    @feedback = current_user.feedbacks.new
  end

  def vote
    vote = @current_organisation.features.new(data_requested: params[:data_requested], recipient_id: params[:id], funder_id: params[:funder_id])
    if vote.save
      redirect_to :back, notice: "Thanks for requesting this, we're working hard to make it happen."
    else
      redirect_to :back, alert: "Unable to vote, perhaps you already did."
    end
  end

  def feedback
    @feedback = current_user.feedbacks.new
  end

  def create_feedback
    @feedback = current_user.feedbacks.new(feedback_params)
    if @feedback.save
      redirect_to :back, notice: "Thanks for your feedback."
    else
      redirect_to :back, alert: "Unable to give feedback, please complete questiions 1-3."
    end
  end

  private

  def load_current_organisation
    @current_organisation = current_user.organisation
  end

  def feedback_params
    params.require(:feedback).permit(:nps, :taken_away, :informs_decision, :other)
  end
end
