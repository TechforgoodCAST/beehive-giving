class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_user_email(params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      redirect_to user_path(user), notice: 'Logged in!'
    else
      redirect_to login_path, alert: 'Incorrect Email or Password'
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to login_url, notice: 'Logged out!'
  end
end
