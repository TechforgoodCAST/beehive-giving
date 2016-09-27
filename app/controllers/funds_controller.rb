class FundsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient, :ensure_proposal_present, :load_proposal

  def home
    # TODO: refactor
    current_user.organisation.proposals.first.initial_recommendation
    @recommended_funds = @recipient.proposals.first.funds.order('recommendations.total_recommendation DESC')
    @popular_funds = Fund.all
    @recommendations = @recipient.proposals.first.recommendations
  end

  def show
    @fund = Fund.find_by(slug: params[:id])
  end

  def tagged
    @tag = ActsAsTaggableOn::Tag.find_by_slug(params[:tag])
    if @tag.present?
      @funds = @recipient.recommended_funds.tagged_with(@tag)
    else
      redirect_to root_path, alert: 'Not found'
    end
  end

end
