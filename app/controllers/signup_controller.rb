class SignupController < ApplicationController
<<<<<<< HEAD
  
  before_filter :ensure_logged_in, except: [:user, :create_user, :unauthorised, :grant_access, :granted_access]
=======

  before_filter :ensure_logged_in, except: [:user, :create_user]
>>>>>>> 37b2085cbf298d6d678a51c5c3a0839ea7d4855f

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
          @user.update_attribute(:last_seen, Time.now)
          UserMailer.welcome_email(@user).deliver
          render :js => "mixpanel.identify('#{@user.id}');
                        mixpanel.people.set({
                          '$first_name': '#{@user.first_name}',
                          '$last_name': '#{@user.last_name}',
                          '$email': '#{@user.user_email}',
                          '$created': '#{@user.created_at}',
                          '$last_login': '#{@user.last_seen}',
                          'Updated At': '#{@user.updated_at}',
                          'Sign In Count': '#{@user.sign_in_count}',
                          'Job Role': '#{@user.job_role}'
                        });
                        window.location.href = '#{signup_organisation_path}';
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
          render :js => "mixpanel.identify('#{current_user.id}');
                        mixpanel.people.set({
                          'Organisation': '#{@organisation.name}',
                          'Country': '#{@organisation.country}',
                          'Registered?': '#{@organisation.registered}',
                          'Founded On': '#{@organisation.founded_on}'
                        });
                        window.location.href = '#{new_recipient_profile_path(@organisation)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        }
        format.html {
          current_user.update_attribute(:organisation_id, @organisation.id)
          redirect_to new_recipient_profile_path(@organisation)
        }    
      elsif ((@organisation.errors.added? :charity_number, :taken) ||
            (@organisation.errors.added? :company_number, :taken)) 

        # If company/charity number has already been taken
        format.js {
          charity_number = @organisation.charity_number
          company_number = @organisation.company_number
          organisation = (Organisation.find_by_charity_number(charity_number) if charity_number) ||
                          (Organisation.find_by_company_nuber(company_number) if company_number)

          current_user.lock_access_to_organisation(organisation.id)

          render :js => "window.location = '#{unauthorised_path}';"
        }
        format.html {
          charity_number = @organisation.charity_number
          company_number = @organisation.company_number
          organisation = (Organisation.find_by_charity_number(charity_number) if charity_number) ||
                          (Organisation.find_by_company_nuber(company_number) if company_number)

          current_user.lock_access_to_organisation(organisation.id)

          redirect_to unauthorised_path
        }
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

  def grant_access
    user = User.find_by_unlock_token(params[:unlock_token])
    user.unlock
    redirect_to granted_access_path(user.first_name)
  end

  def granted_access
    @name = params[:name]
  end

  def unauthorised
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
