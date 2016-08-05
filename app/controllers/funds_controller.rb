class FundsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient

  def home
    @recommended_funds = @recipient.proposals.first.funds.order('recommendations.total_recommendation')
    @popular_funds = Fund.all
  end

end
