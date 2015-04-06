class GrantsController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :load_funder

  def index
    @grants = @funder.grants

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @grants }
    end
  end

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

  def edit
    @grant = @funder.grants.find(params[:id])
  end

  def update
    @grant = @funder.grants.find(params[:id])
    if @grant.update_attributes(grant_params)
      redirect_to funder_path(current_user.organisation)
    else
      render :edit
    end
  end

  private

  def grant_params
    params.require(:grant).permit(:funding_stream, :grant_type, :attention_how, :amount_awarded,
    :amount_applied, :installments, :approved_on, :start_on, :end_on, :attention_on, :applied_on,
    :recipient_id, :funder_id, :days_from_attention_to_applied, :days_from_applied_to_approved,
    :days_form_approval_to_start, :days_from_start_to_end, :country, :open_call)
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:funder_id])
  end
end
