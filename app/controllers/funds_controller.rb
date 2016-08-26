class FundsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient

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

end
