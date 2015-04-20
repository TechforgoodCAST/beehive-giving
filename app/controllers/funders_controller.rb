class FundersController < ApplicationController
  before_filter :ensure_logged_in
  # before_filter :ensure_funder
  before_filter :load_funder, except: [:new, :create]
  before_filter :load_recipient

  respond_to :html

  def index
    @search = Funder.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @funders = @search.result.includes(:funder_attributes, :grants)
  end

  def explore
    @recipient = Recipient.find_by_slug(params[:id])
    @grants = @recipient.grants
    @funder = current_user.organisation
  end

  def show
    @grants = @funder.grants.order("created_at").page(params[:page]).per(10)
  end

  private

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

  #refactor?
  def load_recipient
    @recipient = current_user.organisation if logged_in?
  end
end
