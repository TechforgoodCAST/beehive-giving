class ProfilesController < ApplicationController
  before_filter :load_organisation
  before_filter :load_user
  # before_filter :check_user_ownership

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
    :who_pays, :services_count, :beneficiaries_count, :units_count,
    :beneficiaries_count_actual, :units_count_actual, :income_actual, :expenditure_actual,
    beneficiary_ids: [], country_ids: [], district_ids: [], implementation_ids: [])
  end

  def load_user
    @user = User.find_by_auth_token!(cookies[:auth_token])
  end

  def load_organisation
    @organisation = Organisation.find_by_slug(params[:organisation_id])
  end
end
