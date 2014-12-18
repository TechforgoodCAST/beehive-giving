class OrganisationsController < ApplicationController
  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(organisation_params)
    if @organisation.save
      redirect_to organisation_path(@organisation)
    else
      render :new
    end
  end

  def show
    @organisation = Organisation.find(params[:id])
    @profiles = @organisation.profiles
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name, :contact_name, :contact_role, :contact_email)
  end
end
