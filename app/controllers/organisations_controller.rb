class OrganisationsController < ApplicationController
  before_filter :load_organisation, except: [:new, :create]
  before_filter :check_organisation_ownership, except: [:new, :create]

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(organisation_params)
    if @organisation.save
      session[:logged_in] = true
      session[:organisation_id] = @organisation.id
      OrganisationMailer.welcome_email(@organisation).deliver
      redirect_to organisation_path(@organisation)
    else
      render :new
    end
  end

  def show
    @profiles = @organisation.profiles
  end

  def update
    if @organisation.update_attributes(organisation_params)
      redirect_to organisation_path(@organisation)
    else
      render :edit
    end
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name, :contact_name, :contact_role, :contact_email, :password, :password_confirmation)
  end

  def load_organisation
    @organisation = Organisation.find_by_slug(params[:id])
  end
end
