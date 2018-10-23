# TODO: refactor
class UsersController < ApplicationController
  def agree
    current_user.update_column(:terms_version, TERMS_VERSION)
    redirect_back(fallback_location: root_path)
  end
end
