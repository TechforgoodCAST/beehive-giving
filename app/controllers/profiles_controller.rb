class ProfilesController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient, :prevent_funder_access
  before_filter :ensure_profile_for_current_year, only: [:index, :edit, :update]
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

    respond_to do |format|
      if @profile.save
        format.js   {
          @profile.next_step!
          render :js => "mixpanel.identify('#{current_user.id}');
                        mixpanel.people.set({
                          'Profile State': '#{@profile.state}'
                        });
                        window.location.href = '#{edit_recipient_profile_path(@recipient, @profile)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        }
        format.html {
          @profile.next_step!
          redirect_to edit_recipient_profile_path(@recipient, @profile)
        }
      else
        format.js
        format.html { render :new }
      end
    end
  end

  def index
    @profiles = @recipient.profiles
  end

  def edit; end

  def update
    respond_to do |format|
      if @profile.update_attributes(profile_params)
        format.js   {
          @profile.next_step! unless @profile.state == 'complete'

          if @profile.state == 'complete'
            @recipient.refined_recommendation
            render :js => "mixpanel.identify('#{current_user.id}');
                          mixpanel.people.set({
                            'Profile State': '#{@profile.state}'
                          });
                          window.location.href = '#{recommended_funders_path}';
                          $('button[type=submit]').prop('disabled', true)
                          .removeAttr('data-disable-with');"
          else
            render :js => "mixpanel.identify('#{current_user.id}');
                          mixpanel.people.set({
                            'Profile State': '#{@profile.state}'
                          });
                          window.location.href = '#{edit_recipient_profile_path(@recipient, @profile)}';
                          $('button[type=submit]').prop('disabled', true)
                          .removeAttr('data-disable-with');"
          end
        }
        format.html {
          @profile.next_step! unless @profile.state == 'complete'
          if @profile.state == 'complete'
            @recipient.refined_recommendation
            redirect_to recommended_funders_path
          else
            redirect_to edit_recipient_profile_path(@recipient, @profile)
          end
        }
      else
        format.js
        format.html { render :edit }
      end
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:year, :gender, :min_age, :max_age,
    :income, :expenditure, :volunteer_count, :staff_count, :trustee_count,
    :does_sell, :beneficiaries_count, :beneficiaries_count_actual,
    :income_actual, :expenditure_actual, :beneficiaries_other,
    :beneficiaries_other_required, :implementors_other,
    :implementors_other_required, :implementations_other,
    :implementations_other_required, beneficiary_ids: [], country_ids: [],
    district_ids: [], implementation_ids: [], implementor_ids: [])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

  def load_profile
    @profile = @recipient.profiles.find(params[:id])
  end

end
