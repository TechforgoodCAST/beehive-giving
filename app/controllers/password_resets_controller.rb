class PasswordResetsController < ApplicationController
  def create
    organisation = Organisation.find_by_contact_email(params[:contact_email])
    organisation.send_password_reset if organisation
    redirect_to root_path, notice: 'Email sent with password reset instructions.'
  end

  def edit
    @organisation = Organisation.find_by_password_reset_token!(params[:id])
  end

  def update
    @organisation = Organisation.find_by_password_reset_token!(params[:id])
    if @organisation.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, alert: 'Password reset has expired.'
    elsif @organisation.update_attributes(params.require(:organisation).permit(:password, :password_confirmation))
      redirect_to root_path, notice: 'Password has been reset.'
    else
      render :edit
    end
  end
end
