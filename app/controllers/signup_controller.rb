class SignupController < ApplicationController
  before_filter :ensure_logged_in, except: [:user, :create_user, :grant_access, :granted_access]
  before_filter :load_districts, only: [:user, :create_user]

  def user
    if logged_in?
      redirect_to root_path
    else
      reset_session
      @user = User.new
    end
  end

  def create_user
    @user = User.new(user_params)
    session[:org_type] = @user.org_type
    session[:charity_number] = @user.charity_number
    session[:company_number] = @user.company_number

    respond_to do |format|
      if @user.save
        format.js {
          cookies[:auth_token] = @user.auth_token
          @user.update_attribute(:last_seen, Time.now)
          UserMailer.welcome_email(@user).deliver_now
          if @user.role == 'User'
            render js: "mixpanel.identify('#{@user.id}');
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
                          .removeAttr('data-disable-with');"
          elsif @user.role == 'Funder'
            render js: "window.location.href = '#{new_funder_path}';
                          $('button[type=submit]').prop('disabled', true)
                          .removeAttr('data-disable-with');"
          end
        }
        format.html {
          cookies[:auth_token] = @user.auth_token
          UserMailer.welcome_email(@user).deliver_now
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
    if current_user.organisation
      redirect_to new_recipient_proposal_path(current_user.organisation)
    else
      @recipient = Recipient.new(
        org_type: session[:org_type],
        charity_number: session[:charity_number],
        company_number: session[:company_number]
      )

      case @recipient.org_type
      when 1
        @recipient.scrape_charity_data
      when 2
        @recipient.scrape_company_data
      when 3
        @recipient.scrape_charity_data
        @recipient.scrape_company_data
      end

      # refactor
      if @recipient.save
        current_user.update_attribute(:organisation_id, @recipient.id)
        redirect_to new_recipient_proposal_path(@recipient)
      elsif (@recipient.errors.added? :charity_number, :taken) ||
            (@recipient.errors.added? :company_number, :taken)
        charity_number = @recipient.charity_number
        company_number = @recipient.company_number
        organisation = (Organisation.find_by_charity_number(charity_number) if charity_number) ||
                       (Organisation.find_by_company_number(company_number) if company_number)

        current_user.lock_access_to_organisation(organisation)
        redirect_to unauthorised_path
      else
        render :organisation
      end

    end
  end

  def create_organisation
    @recipient = Recipient.new(recipient_params)
    session[:org_type] = @recipient.org_type
    session[:charity_number] = @recipient.charity_number
    session[:company_number] = @recipient.company_number

    case @recipient.org_type
    when 1
      @recipient.destroy
      @recipient = Recipient.new(recipient_params)
      @recipient.scrape_charity_data
    when 2
      @recipient.destroy
      @recipient = Recipient.new(recipient_params)
      @recipient.scrape_company_data
      @recipient.charity_number = nil
    when 3
      @recipient.destroy
      @recipient = Recipient.new(recipient_params)
      @recipient.scrape_charity_data if @recipient.charity_number.present?
      @recipient.scrape_company_data if @recipient.company_number.present?
    else
      @recipient.registered_on = nil
    end

    respond_to do |format|
      if @recipient.save
        reset_session
        format.js {
          current_user.update_attribute(:organisation_id, @recipient.id)
          render js: "mixpanel.identify('#{current_user.id}');
                        mixpanel.people.set({
                          'Organisation': '#{@recipient.name}',
                          'Country': '#{@recipient.country}',
                          'Registered?': '#{@recipient.registered}',
                          'Founded On': '#{@recipient.founded_on}'
                        });
                        window.location.href = '#{new_recipient_proposal_path(@recipient)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        }
        format.html {
          current_user.update_attribute(:organisation_id, @recipient.id)
          redirect_to new_recipient_proposal_path(@recipient)
        }
      # If company/charity number has already been taken
      elsif (@recipient.errors.added? :charity_number, :taken) ||
            (@recipient.errors.added? :company_number, :taken)
        format.js {
          charity_number = @recipient.charity_number
          company_number = @recipient.company_number
          organisation = (Organisation.find_by_charity_number(charity_number) if charity_number) ||
                         (Organisation.find_by_company_number(company_number) if company_number)

          current_user.lock_access_to_organisation(organisation)
          render js: "window.location.href = '#{unauthorised_path}';"
        }
        format.html {
          charity_number = @recipient.charity_number
          company_number = @recipient.company_number
          organisation = (Organisation.find_by_charity_number(charity_number) if charity_number) ||
                         (Organisation.find_by_company_number(company_number) if company_number)

          current_user.lock_access_to_organisation(organisation)
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
    @user = User.find_by_unlock_token(params[:unlock_token])
    @user.unlock
    redirect_to granted_access_path(@user.unlock_token)
  end

  def granted_access
    @user = User.find_by_unlock_token(params[:unlock_token])
  end

  def unauthorised
    redirect_to root_path if current_user.authorised
  end

  private

    def load_districts
      @districts_count = Funder.active.joins(:countries).group('countries.id').uniq.count
      @districts = Country.order(priority: :desc).order(:name).find(@districts_count.keys)
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :job_role,
      :user_email, :password, :password_confirmation, :role, :agree_to_terms,
      :org_type, :charity_number, :company_number)
    end

    def recipient_params
      params.require(:recipient).permit(:name, :website, :street_address,
        :country, :charity_number, :company_number, :operating_for,
        :multi_national, :income, :employees, :volunteers, :org_type,
        organisation_ids: [])
    end

    def funder_params
      params.require(:funder).permit(:name, :contact_number, :website,
      :street_address, :city, :region, :postal_code, :country, :charity_number,
      :company_number, :founded_on, :registered_on, :mission, :status, :registered, organisation_ids: [])
    end
end
