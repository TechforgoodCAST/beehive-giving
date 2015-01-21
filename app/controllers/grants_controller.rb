class GrantsController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :load_funder

  def new
    @grant = @funder.grants.new
  end

  def create
    @grant = @funder.grants.new(grant_params)
    if @grant.save
      redirect_to funder_path(current_user.organisation)
    else
      render :new
    end
  end

  private

  def grant_params
    params.require(:grant).permit(:funding_stream, :grant_type, :attention_how, :amount_awarded,
    :amount_applied, :installments, :approved_on, :start_on, :end_on, :attention_on, :applied_on,
    :recipient_id, :funder_id)
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:funder_id])
  end
end
