class UsersController < ApplicationController
  before_action :ensure_logged_in

  def edit; end

  def update
    if @current_user.update(user_params)
      redirect_to account_path, notice: 'Updated'
    else
      render :edit
    end
  end
end
