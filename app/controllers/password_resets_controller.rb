class PasswordResetsController < ApplicationController

  def create
    if params[:user_email].present?
      user = User.find_by_user_email(params[:user_email])
      user.send_password_reset if user
      redirect_to sign_in_path, notice: 'Email sent with password reset instructions. Please check your inbox.'
    else
      params[:email_missing] = true
      render :new
    end
  end

  def edit
    if User.find_by_password_reset_token(params[:id])
      @user = User.find_by_password_reset_token(params[:id])
    else
      redirect_to new_password_reset_path, alert: 'Password reset has expired, please request a new password reset.'
    end
  end

  def update
    @user = User.find_by_password_reset_token(params[:id])
    if @user.password_reset_sent_at < 1.hours.ago
      redirect_to new_password_reset_path, alert: 'Password reset has expired, please request a new password reset.'
    elsif @user.update_attributes(params.require(:user).permit(:password, :password_confirmation))
      redirect_to sign_in_path, notice: 'Your password has been reset. Please sign in below.'
    else
      render :edit
    end
  end

end
