class PasswordResetsController < ApplicationController
  before_action :ensure_not_logged_in, if: proc { logged_in? }

  def new
    @password_reset = PasswordReset.new
  end

  def create
    @password_reset = PasswordReset.new(request_params)
    if @password_reset.valid?(:create)
      user = User.find_by(email: request_params[:email])
      user&.send_password_reset
      redirect_to sign_in_path,
                  notice: 'Email sent with password reset instructions. ' \
                          'Please check your inbox.'
    else
      render :new
    end
  end

  def edit
    @user = User.find_by(password_reset_token: params[:id])

    if @user && @user.password_reset_sent_at > 1.hour.ago
      @password_reset = PasswordReset.new(email: @user.email)
    else
      redirect_to new_password_reset_path,
                  alert: 'Password reset has expired, please request a new ' \
                         'password reset.'
    end
  end

  def update
    @password_reset = PasswordReset.new(reset_params)

    if @password_reset.valid?(:update)
      @user = User.find_by(password_reset_token: params[:id])
      @user.update_attributes!(reset_params)
      redirect_to sign_in_path, notice: 'Your password has been reset. Please' \
                                        ' sign in below.'
    else
      render :edit
    end
  end

  private

    def request_params
      params.require(:password_reset).permit(:email)
    end

    def reset_params
      params.require(:password_reset).permit(:password, :password_confirmation)
    end

    def ensure_not_logged_in # TODO: review
      redirect_to root_path, alert: "Sorry, you don't have access to that"
    end
end
