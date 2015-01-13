class UsersController < ApplicationController
  before_filter :load_user, except: [:new, :create]
  before_filter :check_user_ownership, except: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      cookies[:auth_token] = @user.auth_token
      # OrganisationMailer.welcome_email(@organisation).deliver
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show
    @users = User.all
    @organisations = Organisation.all
    # @organisation = @user.organisation
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :job_role,
    :user_email, :password, :password_confirmation, :role)
  end

  def load_user
    @user = User.find(params[:id])
  end
end
