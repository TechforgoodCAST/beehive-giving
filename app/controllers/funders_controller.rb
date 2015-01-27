class FundersController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :ensure_funder
  before_filter :load_funder, except: [:new, :create]

  def show
    @grants = @funder.grants.paginate(:per_page => 10, :page => params[:page])
  end

  private

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end
end
