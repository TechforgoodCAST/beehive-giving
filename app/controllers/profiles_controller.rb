class ProfilesController < ApplicationController
  before_filter :load_organisation

  def new
    @profile = @organisation.profiles.new
  end

  def create
    @profile = @organisation.profiles.new(profile_params)
    if @profile.save
      redirect_to organisation_path(@organisation)
    else
      render :new
    end
  end

  def edit
    @profile = @organisation.profiles.find(params[:id])
  end

  def update
    @profile = @organisation.profiles.find(params[:id])
    if @profile.update_attributes(profile_params)
      redirect_to organisation_path(@organisation)
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:year, :gender, :currency, :goods_services, :who_pays, :who_buys,
    :min_age, :max_age, :income, :expenditure, :volunteer_count,
    :staff_count, :job_role_count, :department_count, :goods_count,
    :units_count, :services_count, :beneficiaries_count)
  end

  def load_organisation
    @organisation = Organisation.find_by_slug(params[:organisation_id])
  end
end
