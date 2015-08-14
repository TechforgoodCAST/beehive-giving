class SignupController < ApplicationController
  before_filter :ensure_logged_in, except: [:user, :create_user]

  def user
    if logged_in?
      redirect_to root_path
    else
      @user = User.new
    end
  end

  def create_user
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html {
          cookies[:auth_token] = @user.auth_token
          UserMailer.welcome_email(@user).deliver
          redirect_to signup_organisation_path if @user.role == 'User'
          redirect_to new_funder_path if @user.role == 'Funder'
        }
        format.js   {
          cookies[:auth_token] = @user.auth_token
          UserMailer.welcome_email(@user).deliver
          render :js => "window.location = '#{signup_organisation_path}'" if @user.role == 'User'
          render :js => "window.location = '#{new_funder_path}'" if @user.role == 'Funder'
        }
      else
        format.html { render :user }
        format.js
      end
    end
  end

  def organisation
    if current_user.organisation_id
      redirect_to funders_path
    else
      @organisation = Recipient.new
    end
  end

  def create_organisation
    @organisation = Recipient.new(organisation_params)
    if @organisation.save
      current_user.update_attribute(:organisation_id, @organisation.id)
      @organisation.initial_recommendation
      redirect_to funders_path
    else
      render :organisation
    end
  end

  def funder
    @funder = Funder.new
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

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :job_role,
    :user_email, :password, :password_confirmation, :role, :agree_to_terms)
  end

  def organisation_params
    params.require(:recipient).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :country, :charity_number,
    :company_number, :founded_on, :registered_on, :mission, :status, :registered, organisation_ids: [])
  end

  def funder_params
    params.require(:funder).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :country, :charity_number,
    :company_number, :founded_on, :registered_on, :mission, :status, :registered, organisation_ids: [])
  end
end
