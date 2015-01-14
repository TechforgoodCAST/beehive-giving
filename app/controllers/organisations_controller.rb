class OrganisationsController < ApplicationController
  before_filter :load_organisation, except: [:new, :create]
  before_filter :load_user
  # before_filter :check_user_ownership

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(organisation_params)
    if @organisation.save
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show
    @organisations = Organisation.all
    @profiles = @organisation.profiles
    @users = @organisation.users
    @grants = Grant.all
  end

  def update
    if @organisation.update_attributes(organisation_params)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @organisation.destroy
    flash[:success] = "Organisation deleted"
    redirect_to user_path(@user)
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :charity_number,
    :company_number, :founded_on, :registered_on, :type, organisation_ids: [])
  end

  def load_organisation
    @organisation = Organisation.find_by_slug(params[:id])
  end

  def load_user
    @user = User.find_by_auth_token!(cookies[:auth_token])
  end
end
