class OrganisationsController < ApplicationController
  before_filter :ensure_logged_in
  # before_filter :load_organisation, except: [:new, :create]
  # before_filter :check_organisation_ownership
  #
  # before_filter :load_user

  # def new
  #   @organisation = Organisation.new
  # end
  #
  # def create
  #   @organisation = Organisation.new(organisation_params)
  #   if @organisation.save
  #     redirect_to user_path(@user)
  #   else
  #     render :new
  #   end
  # end

  # def show
  #   @organisations = Organisation.all
  #   @profiles = @organisation.profiles
  #   @users = @organisation.users
  #   @grants = @organisation.grants
  # end
  #
  # def update
  #   if @organisation.update_attributes(organisation_params)
  #     redirect_to organisation_path(@organisation)
  #   else
  #     render :edit
  #   end
  # end
  #
  # def destroy
  #   @organisation.destroy
  #   flash[:success] = "Organisation deleted"
  #   redirect_to user_path(@user)
  # end
  #
  # private
  #
  # def organisation_params
  #   params.require(:organisation).permit(:name, :contact_number, :website,
  #   :street_address, :city, :region, :postal_code, :charity_number,
  #   :company_number, :founded_on, :registered_on, :organisation_type, organisation_ids: [])
  # end
  #
  # def load_organisation
  #   @organisation = Recipient.find_by_slug(params[:id])
  # end
  #
  # def load_user
  #   @user = User.find_by_auth_token!(cookies[:auth_token])
  # end
end
