class ProfilesController < ApplicationController
  before_filter :load_recipient
  before_filter :load_profile, :only => [:edit, :update, :destroy]

  def new
    if !@recipient || @recipient.profiles.count == 1
      redirect_to root_path
    else
      @profile = @recipient.profiles.new
    end
  end

  def create
    @profile = @recipient.profiles.new(profile_params)
    if @profile.save
      UserMailer.notify_funder(@profile).deliver
      redirect_to recipient_dashboard_path
    else
      render :profile
    end
  end

  def index
    @profiles = @recipient.profiles
  end

  def edit
  end

  def destroy
    @profile.destroy
    redirect_to recipient_profiles_path(@recipient)
  end

  def update
    if @profile.update_attributes(profile_params)
      redirect_to recipient_profiles_path(@recipient)
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

  def load_recipient
    @recipient = current_user.organisation
  end

  def load_profile
    @profile = @recipient.profiles.find(params[:id])
  end
end
