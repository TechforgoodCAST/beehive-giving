class UsersController < ApplicationController
  def terms_version
    current_user.update_column(:terms_version, TERMS_VERSION)
    redirect_back(fallback_location: root_path)
  end

  def update_version
    current_user.update_column(:update_version, UPDATE_VERSION)
    redirect_back(fallback_location: root_path)
  end
end
