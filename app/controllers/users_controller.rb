class UsersController < ApplicationController
  before_action :ensure_logged_in

  def update
    if @current_user.update(user_params)
      redirect_to account_path, notice: 'Updated'
    else
      render :edit
    end
  end

  def agree
    @current_user.update_column(:terms_version, TERMS_VERSION)
    redirect_back(fallback_location: funds_path(@proposal))
  end
end
