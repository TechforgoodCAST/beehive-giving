class UsersController < ApplicationController

  before_filter :ensure_logged_in, :load_organisation
  before_filter :load_user, except: [:new, :create]
  before_filter :check_user_ownership, except: [:new, :create]

  def index
    @organisations = Organisation.search(params[:search])
  end

  def show
    @users = User.all
    @organisations = Organisation.all
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

  def load_organisation
    @organisation = Organisation.find_by_slug(params[:organisation_id])
  end
  
end
