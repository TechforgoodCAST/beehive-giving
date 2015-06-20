class RecommendationsController < ApplicationController

  before_filter :load_funder, :load_recipient

  def edit
    @recommendation = Recommendation.where(recipient: @recipient, funder: @funder).first

    if @recommendation.recommendation_quality.present?
      redirect_to recipient_comparison_path(@funder, proceed: true)
    else
      render :edit
    end
  end

  def update
    @recommendation = Recommendation.where(recipient: @recipient, funder: @funder).first_or_initialize

    if @recommendation.update_attributes(enquiry_params)
      redirect_to recipient_comparison_path(@funder, proceed: true)
    else
      render :edit
    end
  end

  private

  def enquiry_params
    params.require(:recommendation).permit(:recommendation_quality)
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

end
