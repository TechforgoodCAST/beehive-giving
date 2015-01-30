class FundersController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :ensure_funder
  before_filter :load_funder, except: [:new, :create]

  respond_to :html

  def index
    @search = Funder.search(params[:q])
    @funders = @search.result(distinct: true)

    respond_with @funders
  end

  def show
    @grants = @funder.grants.paginate(:per_page => 10, :page => params[:page])
  end

  private

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end
end
