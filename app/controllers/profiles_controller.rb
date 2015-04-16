class ProfilesController < ApplicationController
  before_filter :load_recipient
  before_filter :load_profile, :only => [:edit, :update, :destroy]

  def new
    @redirect_to_funder = params[:redirect_to_funder]
    if !@recipient || !@recipient.can_create_profile?
      flash[:alert] = "Sorry you can't create a profile"
      redirect_to root_path
    else
      @profile = @recipient.profiles.new
    end
  end

  def create
    @redirect_to_funder = params[:profile].delete(:redirect_to_funder)
    @profile = @recipient.profiles.new(profile_params)
    if @profile.save
      UserMailer.notify_funder(@profile).deliver
      if @redirect_to_funder
        redirect_to recipient_comparison_path(Funder.find(@redirect_to_funder))
      else
        redirect_to recipient_profiles_path(@recipient), notice: 'Profile created'
      end
    else
      render :new
    end
  end

  def index
    @profiles = @recipient.profiles
  end

  def edit
  end

  def update
    if @profile.update_attributes(profile_params)
      redirect_to recipient_profiles_path(@recipient), notice: 'Profile saved'
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:year, :gender, :min_age, :max_age,
    :income, :expenditure, :volunteer_count, :staff_count, :does_sell,
    :beneficiaries_count, :beneficiaries_count_actual, :income_actual,
    :expenditure_actual, beneficiary_ids: [], country_ids: [], district_ids: [],
    implementation_ids: [], implementor_ids: [])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

  def load_profile
    @profile = @recipient.profiles.find(params[:id])
  end
end
