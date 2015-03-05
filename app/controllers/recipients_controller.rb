class RecipientsController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :load_recipient
  before_filter :load_funder, :only => [:gateway, :unlock_funder, :comparison]
  before_filter :load_feedback, :only => [:dashboard, :gateway, :comparison]

  def dashboard
    @search = Funder.search(params[:q])
    @funders = @search.result(distinct: true)
  end

  def gateway
  end

  def unlock_funder
    @recipient.unlock_funder!(@funder) if @recipient.locked_funder?(@funder)
    redirect_to recipient_comparison_path(@funder)
  end

  def comparison
    redirect_to recipient_comparison_gateway_path(@funder) if @recipient.locked_funder?(@funder)
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

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

  def load_feedback
    @feedback = current_user.feedbacks.new
  end

end
