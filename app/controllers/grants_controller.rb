class GrantsController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :load_funder

  # def organisation
  #   @organisation = Organisation.new
  # end
  #
  # def create_organisation
  #   @organisation = Recipient.new(organisation_params)
  #   if @organisation.save
  #     current_user.update_attribute(:organisation_id, @organisation.id)
  #     redirect_to signup_profile_path
  #   else
  #     render :organisation
  #   end
  # end

  def new
    @grant = @funder.grants.new
  end

  def create
    @grant = @funder.grants.new(grant_params)
    # @grant.update_attribute(:recipient_id, :recipient)
    if @grant.save
      redirect_to funder_path(current_user.organisation)
    else
      render :new
    end
  end

  # def edit
  #   @grant = @organisation.grants.find(params[:id])
  # end
  #
  # def update
  #   @grant = @organisation.grants.find(params[:id])
  #   if @grant.update_attributes(grant_params)
  #     redirect_to organisation_path(@organisation)
  #   else
  #     render :edit
  #   end
  # end

  private

  def grant_params
    params.require(:grant).permit(:funding_stream, :grant_type, :attention_how, :amount_awarded,
    :amount_applied, :installments, :approved_on, :start_on, :end_on, :attention_on, :applied_on,
    :recipient_id)
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:funder_id])
  end
end
