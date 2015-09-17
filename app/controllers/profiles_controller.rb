class ProfilesController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient
  before_filter :load_profile, :only => [:edit, :update, :destroy]

  def new
    if !@recipient || !@recipient.can_create_profile?
      flash[:alert] = "Sorry you can't create more than one profile a year, why not edit the one you've already created."
      redirect_to edit_recipient_profile_path(current_user.organisation, current_user.organisation.profiles.where(year: Date.today.year).first)
    else
      @profile = @recipient.profiles.new
      @profile.state = 'beneficiaries'
    end
  end

  def create
    @profile = @recipient.profiles.new(profile_params)
    if @profile.save
      @profile.next_step!
      redirect_to edit_recipient_profile_path(@recipient, @profile)
    else
      render :new
    end
  end

  def index
    @profiles = @recipient.profiles
  end

  def edit; end

  def update
    if @profile.update_attributes(profile_params)
      @profile.next_step! unless @profile.state == 'complete'
      if @profile.state == 'complete'
        @recipient.refined_recommendation
        UserMailer.notify_funder(@profile).deliver
        redirect_to funders_path
      else
        redirect_to edit_recipient_profile_path(@recipient, @profile)
      end
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:year, :gender, :min_age, :max_age,
    :income, :expenditure, :volunteer_count, :staff_count, :trustee_count,
    :does_sell, :beneficiaries_count, :beneficiaries_count_actual,
    :income_actual, :expenditure_actual, beneficiary_ids: [], country_ids: [],
    district_ids: [], implementation_ids: [], implementor_ids: [])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

  def load_profile
    @profile = @recipient.profiles.find(params[:id])
  end

end
