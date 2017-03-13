class UsersController < ApplicationController
  def edit; end

  def update
    if @current_user.update(user_params)
      redirect_to account_path, notice: 'Updated'
    else
      render :edit
    end
  end
end
