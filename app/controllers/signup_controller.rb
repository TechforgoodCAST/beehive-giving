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
        format.js   {
          cookies[:auth_token] = @user.auth_token
          UserMailer.welcome_email(@user).deliver
          render :js => "window.location.href = '#{signup_organisation_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');" if @user.role == 'User'
          render :js => "window.location.href = '#{new_funder_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');" if @user.role == 'Funder'
        }
        format.html {
          cookies[:auth_token] = @user.auth_token
          UserMailer.welcome_email(@user).deliver
          redirect_to signup_organisation_path if @user.role == 'User'
          redirect_to new_funder_path if @user.role == 'Funder'
        }
      else
        format.js
        format.html { render :user }
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

    respond_to do |format|
      if @organisation.save
        format.js   {
          current_user.update_attribute(:organisation_id, @organisation.id)
          @organisation.initial_recommendation
          render :js => "window.location.href = '#{funders_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        }
        format.html {
          current_user.update_attribute(:organisation_id, @organisation.id)
          @organisation.initial_recommendation
          redirect_to funders_path
        }    
      elsif ((@organisation.errors.added? :charity_number, :taken) ||
        (@organisation.errors.added? :company_number, :taken)) 
        # If company/charity number has already been taken
        charity_number = @organisation.charity_number
        company_number = @organisation.company_number
        organisation = (Organisation.find_by_charity_number(charity_number) if charity_number) ||
                        (Organisation.find_by_company_nuber(company_number) if company_number)

        current_user.update_attribute(:authorised, false) 
        current_user.update_attribute(:organisation_id, organisation.id)
        # send relevant email
        organisation.send_authorisation_email(current_user.id)
        redirect_to unauthorised_path
        # send email to existing user or admin
        # add user to organisation (Organisation.add new user relationship)
        # redirect requesting user to holding page and send email
        # ensure user can only visit holding page until authorized
      else
        format.js
        format.html { render :organisation }
      end
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
