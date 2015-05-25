class FundersController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :ensure_admin, only: [:comparison]
  before_filter :ensure_funder, only: [:explore, :show]
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

  def comparison
    # refactor
    @funders = [
      Funder.find_by_name('The Foundation'),
      Funder.find_by_name('The Dulverton Trust'),
      Funder.find_by_name('Paul Hamlyn Foundation'),
      Funder.find_by_name('The Indigo Trust'),
      Funder.find_by_name('Nominet Trust')
    ]

    # refactor
    gon.funderName1 = Funder.find_by_name('The Foundation').name
    gon.funderName2 = Funder.find_by_name('The Dulverton Trust').name
    gon.funderName3 = Funder.find_by_name('Paul Hamlyn Foundation').name
    gon.funderName4 = Funder.find_by_name('The Indigo Trust').name
    gon.funderName5 = Funder.find_by_name('Nominet Trust').name
  end

  def eligibility
    @funder = Funder.find_by_slug(params[:funder_id])
    @restrictions = @funder.restrictions.uniq

    if @recipient.questions_remaining?(@funder)
      redirect_to recipient_eligibility_path(@funder)
    elsif @recipient.eligible?(@funder)
      render :eligibility
    else
      flash[:alert] = "Sorry you're ineligible"
      redirect_to recipient_comparison_path(@funder)
    end
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
