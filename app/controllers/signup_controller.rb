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
      redirect_to signup_organisation_path if @user.role == 'User'
      redirect_to new_funder_path if @user.role == 'Funder'
    else
      render :user
    end
  end

  def organisation
    if current_user.organisation_id
      redirect_to root_path
    else
      @organisation = Organisation.new
    end
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

  def funder
    @funder = Organisation.new
  end

  def create_funder
    @funder = Funder.new(funder_params)
    if @funder.save
      current_user.update_attribute(:organisation_id, @funder.id)
      redirect_to funder_path(current_user.organisation)
    else
      render :funder
    end
  end

  def profile
    @organisation = current_user.organisation
    if !@organisation || @organisation.profiles.count == 1
      redirect_to root_path
    else
      @profile = @organisation.profiles.new
    end
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
    @organisation = current_user.organisation
    if @organisation && @organisation.profiles.count == 1
      render :comparison
    else
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :job_role,
    :user_email, :password, :password_confirmation, :role)
  end

  def organisation_params
    params.require(:organisation).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :country, :charity_number,
    :company_number, :founded_on, :registered_on, organisation_ids: [])
  end

  def funder_params
    params.require(:organisation).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :country, :charity_number,
    :company_number, :founded_on, :registered_on, organisation_ids: [])
  end

  def profile_params
    params.require(:profile).permit(:year, :gender, :currency, :goods_services, :who_pays, :who_buys,
    :min_age, :max_age, :income, :expenditure, :volunteer_count,
    :staff_count, :job_role_count, :department_count, :goods_count,
    :units_count, :services_count, :beneficiaries_count, beneficiary_ids: [], country_ids: [], district_ids: [])
  end
end
