class SignupController < ApplicationController
  before_action :ensure_logged_in, :ensure_not_signed_up, only: :unauthorised

  def user
    if logged_in?
      redirect_to start_path
    else
      reset_session
      @user = User.new
    end
  end

  def create_user
    @user = User.new(user_params.merge(terms_version: TERMS_VERSION))
    session[:org_type] = @user.org_type
    session[:charity_number] = @user.charity_number
    session[:company_number] = @user.company_number

    respond_to do |format|
      if @user.save
        format.js do
          cookies[:auth_token] = @user.auth_token
          @user.update_attribute(:last_seen, Time.zone.now)
          UserMailer.welcome_email(@user).deliver_now
          render js: "mixpanel.identify('#{@user.id}');
                        mixpanel.people.set({
                          '$first_name': '#{@user.first_name}',
                          '$last_name': '#{@user.last_name}',
                          '$email': '#{@user.email}',
                          '$created': '#{@user.created_at}',
                          '$last_login': '#{@user.last_seen}',
                          'Updated At': '#{@user.updated_at}',
                          'Sign In Count': '#{@user.sign_in_count}'
                        });
                        window.location.href = '#{new_signup_recipient_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        end
        format.html do
          cookies[:auth_token] = @user.auth_token
          UserMailer.welcome_email(@user).deliver_now
          redirect_to new_signup_recipient_path
        end
      else
        format.js
        format.html { render :user }
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
end
