class FundersController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :ensure_admin, only: [:comparison]
  before_filter :ensure_funder, only: [:explore, :show]
  before_filter :load_funder, except: [:new, :create]
  before_filter :load_recipient

  respond_to :html

  def index
    @search = Funder.ransack(params[:q])
    @search.sorts = ['active_on_beehive desc', 'name asc'] if @search.sorts.empty?
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

  def comparison
    @funders = Funder.where(name: ['The Foundation',
                    'The Dulverton Trust',
                    'Paul Hamlyn Foundation',
                    'The Indigo Trust',
                    'Nominet Trust']).to_a

    gon.funderName1 = @funders[0].name
    gon.funderName2 = @funders[1].name
    gon.funderName3 = @funders[2].name
    gon.funderName4 = @funders[3].name
    gon.funderName5 = @funders[4].name
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
