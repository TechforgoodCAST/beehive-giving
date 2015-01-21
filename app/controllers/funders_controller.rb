class FundersController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :load_funder, except: [:new, :create]

  def show
    # @organisations = Funder.all
    # @profiles = @organisation.profiles
    # @users = @organisation.users
    @grants = @funder.grants
    # @recipient = @funder.grants.recipient
  end

  private

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end
end
