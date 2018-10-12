# TODO: refactor
class UsersController < ApplicationController
  def agree
    current_user.update_column(:terms_version, TERMS_VERSION)
    redirect_back(fallback_location: funds_path(@proposal))
  end
end
