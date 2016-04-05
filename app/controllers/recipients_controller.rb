class RecipientsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient, :years_ago
  before_filter :check_organisation_ownership_or_funder, :only => :show
  before_filter :load_funder, :only => [:comparison, :eligibility, :update_eligibility, :apply]
  before_filter :load_feedback, :except => [:unlock_funder, :vote]
  before_filter :funder_attribute, :only => [:comparison, :eligibility, :update_eligibility]

  def recommended_funders
    @funders = @recipient.recommended_with_eligible_funders

    render 'recipients/funders/recommended_funders'
  end

  def eligible_funders
    @funders = Funder.find(@recipient.recommendations.where(eligibility: 'Eligible').pluck(:funder_id))

    render 'recipients/funders/eligible_funders'
  end

  def ineligible_funders
    @funders = Funder.find(@recipient.recommendations.where(eligibility: 'Ineligible').pluck(:funder_id))

    render 'recipients/funders/ineligible_funders'
  end

  def all_funders
    @search = Funder.where(active_on_beehive: true).where('recommendations.recipient_id = ?', @recipient.id).ransack(params[:q])
    @search.sorts = ['recommendations_score desc', 'name asc'] if @search.sorts.empty?
    @funders = @search.result

    respond_to do |format|
      format.html { render 'recipients/funders/all_funders' }
      format.js
    end
  end

  def dashboard
    @search = Funder.ransack(params[:q])
    @profile = @recipient.profiles.where('year = ?', 2015).first
  end

  # refactor
  def show
    @recipient = Recipient.find_by_slug(params[:id])
  end

  def eligibility
    @restrictions = @funder.restrictions.order(:id).uniq
    @eligibility =  1.times { @restrictions.each { |r| @recipient.eligibilities.new(restriction_id: r.id) unless @recipient.eligibilities.where('restriction_id = ?', r.id).count > 0 } }

    if current_user.feedbacks.count < 1 && @recipient.unlocked_funders.count == 2
      session[:redirect_to_funder] = @funder.slug
      redirect_to new_feedback_path
    elsif @recipient.can_unlock_funder?(@funder) || !@recipient.locked_funder?(@funder)
      render :eligibility
    else
      # refactor redirect to upgrade path
      redirect_to edit_feedback_path(current_user.feedbacks.last)
    end
  end

  def update_eligibility
    @restrictions = @funder.restrictions

    if @recipient.update_attributes(eligibility_params)
      @recipient.unlock_funder!(@funder) if @recipient.locked_funder?(@funder)
      @recipient.check_eligibility(@funder)
      render :eligibility
    else
      render :eligibility
    end
  end

  def apply
    if @recipient.eligible?(@funder) && @recipient.has_proposal?
      render 'recipients/funders/apply'
    elsif !@recipient.has_proposal?
      flash[:alert] = 'Please provide details of your funding request before applying.'
      redirect_to new_recipient_proposal_path(@recipient, return_to: @funder)
    else
      flash[:alert] = 'You need to check your eligibility before applying.'
      redirect_to recipient_eligibility_path(@funder)
    end
  end

  private

  def load_recipient
    @recipient = current_user.organisation if logged_in?
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

  def load_feedback
    @feedback = current_user.feedbacks.new if logged_in?
  end

  def years_ago
    if params[:years_ago].present?
      @years_ago = params[:years_ago].to_i
    else
      @years_ago = 1
    end
  end

  #refactor?
  def funder_attribute
    @funding_stream = params[:funding_stream] || 'All'

    if @funder.attributes.any?
      @year_of_funding = @funder.attributes.where('grant_count > ?', 0).order(year: :desc).first.year
      @funder_attribute = @funder.attributes.where('year = ? AND funding_stream = ?', @year_of_funding, @funding_stream).first
    end
  end

  def eligibility_params
    params.require(:recipient).permit(eligibilities_attributes: [:id, :eligible, :restriction_id, :recipient_id])
  end

end
