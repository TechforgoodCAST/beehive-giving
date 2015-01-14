class GrantsController < ApplicationController
  before_filter :load_organisation
  before_filter :load_user
  before_filter :check_user_ownership

  def new
    @grant = @organisation.grants.new
  end

  def create
    @grant = @organisation.grants.new(grant_params)
    if @grant.save
      redirect_to organisation_path(@organisation)
    else
      render :new
    end
  end

  def edit
    @grant = @organisation.grants.find(params[:id])
  end

  def update
    @grant = @organisation.grants.find(params[:id])
    if @grant.update_attributes(grant_params)
      redirect_to organisation_path(@organisation)
    else
      render :edit
    end
  end

  private

  def grant_params
    params.require(:grant).permit(:funding_stream, :grant_type, :attention_how, :amount_awarded,
    :amount_applied, :installments, :approved_on, :start_on, :end_on, :attention_on, :applied_on)
  end

  def load_organisation
    @organisation = Organisation.find_by_slug(params[:organisation_id])
  end

  def load_user
    @user = User.find_by_auth_token!(cookies[:auth_token])
  end
end
