class RecipientsController < ApplicationController
  before_filter :ensure_logged_in
  # before_filter :ensure_funder
  before_filter :load_recipient

  def show
    @grants = @recipient.grants
    @funder = current_user.organisation
  end

  def dashboard
    @funders = Funder.all
    @features = @recipient.features
    @feature = Feature.find_by_recipient_id(params[:id])
  end

  def comparison
    @funder = Funder.find_by_slug(params[:id])
  end

  def vote
    vote = @recipient.features.new(data_requested: params[:data_requested], recipient_id: params[:id], funder_id: params[:funder_id])
    if vote.save
      redirect_to :back, notice: "Thanks for requesting this, we're working hard to make it happen."
    else
      redirect_to :back, alert: "Unable to vote, perhaps you already did."
    end
  end

  private

  def load_recipient
    @recipient = current_user.organisation
  end
end
