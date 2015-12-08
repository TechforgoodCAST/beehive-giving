class PasswordResetsController < ApplicationController

  def create
    user = User.find_by_user_email(params[:user_email])
    user.send_password_reset if user
    redirect_to root_path
    flash[:notice] = 'Email sent with password reset instructions.' if params[:user_email].present?
  end

  def edit
    if User.find_by_password_reset_token(params[:id])
      @user = User.find_by_password_reset_token(params[:id])
    else
      redirect_to welcome_path
    end
  end

  def update
    @user = User.find_by_password_reset_token(params[:id])
    if @user.password_reset_sent_at < 1.hours.ago
      redirect_to new_password_reset_path, alert: 'Password reset has expired, please request a new password reset.'
    elsif @user.update_attributes(params.require(:user).permit(:password, :password_confirmation))
      redirect_to root_path, notice: 'Password has been reset.'
    else
      render :edit
    end
  end

end
