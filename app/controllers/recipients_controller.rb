class RecipientsController < ApplicationController
  before_filter :check_organisation_ownership_or_funder, :only => [:show]
  before_filter :ensure_logged_in, :load_recipient, :years_ago
  before_filter :load_funder, :only => [:gateway, :unlock_funder, :comparison]
  before_filter :load_feedback, :only => [:dashboard, :gateway, :comparison, :show]

  def dashboard
    @search = Funder.ransack(params[:q])
  end

  def gateway
    redirect_to recipient_comparison_path(@funder) unless @recipient.locked_funder?(@funder)
  end

  def unlock_funder
    @recipient.unlock_funder!(@funder) if @recipient.locked_funder?(@funder)
    redirect_to recipient_comparison_path(@funder)
  end

  def comparison
    redirect_to recipient_comparison_gateway_path(@funder) if @recipient.locked_funder?(@funder)
    @funding_stream = params[:funding_stream]
  end

  def vote
    vote = Feature.find_or_initialize_by(recipient_id: params[:recipient_id], funder_id: params[:funder_id])

    vote.update_attributes(
      data_requested: vote.data_requested || params[:data_requested],
      request_amount_awarded: vote.request_amount_awarded || params[:request_amount_awarded],
      request_funding_dates: vote.request_funding_dates || params[:request_funding_dates],
      request_funding_countries: vote.request_funding_countries || params[:request_funding_countries]
    )

    if vote.save
      redirect_to :back, notice: "Thanks for requesting this, your interest helps us decide what to focus on - watch this space..."
    else
      redirect_to :back, alert: "Unable to vote, perhaps you already did?"
    end
  end

  def show
    @recipient = Recipient.find_by_slug(params[:id])
  end

  private

  def load_recipient
    @recipient = current_user.organisation if logged_in?
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

  def load_feedback
    @feedback = current_user.feedbacks.new if logged_in?
  end

  def years_ago
    if params[:years_ago].present?
      @years_ago = params[:years_ago].to_i
    else
      @years_ago = 1
    end
  end

end
