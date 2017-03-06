class SignupController < ApplicationController
  before_action :ensure_logged_in, :ensure_not_signed_up, only: [
    :organisation, :create_organisation, :unauthorised
  ]
  before_action :load_districts, only: [:user, :create_user]

  def user
    if logged_in?
      redirect_to start_path
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
        format.js do
          cookies[:auth_token] = @user.auth_token
          @user.update_attribute(:last_seen, Time.zone.now)
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
        end
        format.html do
          cookies[:auth_token] = @user.auth_token
          UserMailer.welcome_email(@user).deliver_now
          redirect_to signup_organisation_path if @user.role == 'User'
          redirect_to new_funder_path if @user.role == 'Funder'
        end
      else
        format.js
        format.html { render :user }
      end
    end
  end

  def organisation
    @recipient = Recipient.new(org_type:       session[:org_type],
                               charity_number: session[:charity_number],
                               company_number: session[:company_number])

    @scrape_success = @recipient.scrape_org
    return unless @scrape_success
    # refactor
    if @recipient.save
      current_user.update_attribute(:organisation_id, @recipient.id)
      redirect_to new_signup_proposal_path
    elsif (@recipient.errors.added? :charity_number, :taken) ||
          (@recipient.errors.added? :company_number, :taken)
      organisation = @recipient.find_with_reg_nos
      current_user.lock_access_to_organisation(organisation)
      redirect_to unauthorised_path
    end
  end

  def create_organisation
    @recipient = Recipient.new(recipient_params)
    session[:org_type] = @recipient.org_type
    session[:charity_number] = @recipient.charity_number
    session[:company_number] = @recipient.company_number

    @scrape_success = @recipient.scrape_org

    respond_to do |format|
      if @recipient.save
        reset_session
        format.js do
          current_user.update_attribute(:organisation_id, @recipient.id)
          render js: "mixpanel.identify('#{current_user.id}');
                        mixpanel.people.set({
                          'Organisation': '#{@recipient.name}',
                          'Country': '#{@recipient.country}',
                          'Registered?': '#{@recipient.registered}',
                          'Founded On': '#{@recipient.founded_on}'
                        });
                        window.location.href = '#{new_signup_proposal_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        end
        format.html do
          current_user.update_attribute(:organisation_id, @recipient.id)
          redirect_to new_signup_proposal_path
        end
      # If company/charity number has already been taken
      elsif (@recipient.errors.added? :charity_number, :taken) ||
            (@recipient.errors.added? :company_number, :taken)
        format.js do
          organisation = @recipient.find_with_reg_nos
          current_user.lock_access_to_organisation(organisation)
          render js: "window.location.href = '#{unauthorised_path}';"
        end
        format.html do
          organisation = @recipient.find_with_reg_nos
          current_user.lock_access_to_organisation(organisation)
          redirect_to unauthorised_path
        end
      else
        format.js
        format.html { render :organisation }
      end
    end
  end

  def grant_access # TODO: refactor into UnauthorisedController
    @user = User.find_by(unlock_token: params[:unlock_token])
    @user.unlock
    redirect_to granted_access_path(@user.unlock_token)
  end

  def granted_access # TODO: refactor into UnauthorisedController
    @user = User.find_by(unlock_token: params[:unlock_token])
  end

  # def unauthorised # TODO: refactor into UnauthorisedController
  # end

  private

    def load_districts
      @districts = Fund.active.joins(:countries).group('countries.name')
                       .count.to_a
    end
end
