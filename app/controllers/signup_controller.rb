class SignupController < ApplicationController
  before_filter :ensure_logged_in, except: [:user, :create_user]

  def user
    @user = User.new
  end

  def create_user
    @user = User.new(user_params)
    if @user.save
      cookies[:auth_token] = @user.auth_token
      # OrganisationMailer.welcome_email(@organisation).deliver
      redirect_to signup_organisation_path
    else
      render :user
    end
  end

  def organisation
    @organisation = Organisation.new
  end

  def create_organisation
    @organisation = Recipient.new(organisation_params)
    if @organisation.save
      current_user.update_attribute(:organisation_id, @organisation.id)
      redirect_to signup_profile_path
    else
      render :organisation
    end
  end

  def profile
    @organisation = current_user.organisation
    @profile = @organisation.profiles.new
  end

  def create_profile
    @organisation = current_user.organisation
    @profile = @organisation.profiles.new(profile_params)
    if @profile.save
      redirect_to signup_comparison_path
    else
      render :profile
    end
  end

  def comparison

  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :job_role,
    :user_email, :password, :password_confirmation, :role)
  end

  def organisation_params
    params.require(:organisation).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :charity_number,
    :company_number, :founded_on, :registered_on, organisation_ids: [])
  end

  def profile_params
    params.require(:profile).permit(:year, :gender, :currency, :goods_services, :who_pays, :who_buys,
    :min_age, :max_age, :income, :expenditure, :volunteer_count,
    :staff_count, :job_role_count, :department_count, :goods_count,
    :units_count, :services_count, :beneficiaries_count, beneficiary_ids: [])
  end
end
