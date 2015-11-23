class FundersController < ApplicationController

  before_filter :ensure_logged_in
  before_filter :ensure_admin, only: [:comparison]
  before_filter :ensure_funder, only: [:explore, :eligible]
  before_filter :ensure_profile_for_current_year, only: [:show]
  before_filter :load_funder, except: [:new, :create]
  before_filter :load_recipient

  respond_to :html

  # def index
  #   @search = Funder.where(active_on_beehive: true).where('recommendations.recipient_id = ?', @recipient.id).ransack(params[:q])
  #   @search.sorts = ['recommendations_score desc', 'name asc'] if @search.sorts.empty?
  #   @funders = @search.result
  #
  #   respond_to do |format|
  #     format.html
  #     format.js
  #   end
  # end

  def explore
    @recipient = Recipient.find_by_slug(params[:id])
    @grants = @recipient.grants
    @funder = current_user.organisation
  end

  def show
    @restrictions = @funder.restrictions.uniq

    unless @recipient.is_subscribed? || @recipient.recommended_funder?(@funder)
      redirect_to edit_feedback_path(current_user.feedbacks.last)
    end
  end

  def eligible
    @eligible_organisations = @funder.eligible_organisations
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
