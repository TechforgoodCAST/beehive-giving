class EnquiriesController < ApplicationController

  before_filter :load_funder, :load_recipient

  respond_to :js

  def approach_funder
    @recommendation = Recommendation.where(recipient: @recipient, funder: @funder).first
  end

  def apply
    @enquiry = Enquiry.where(recipient: @recipient, funder: @funder, funding_stream: params[:funding_stream]).first_or_create
    @enquiry.increment!(:approach_funder_count)
    @enquiry.update_attributes(funding_stream: params[:funding_stream])

    @funding_stream_id = "#{params[:funding_stream].downcase.gsub(/[^a-z0-9]+/, '-')}"
    @funder_attribute = @funder.attributes.where(funding_stream: params[:funding_stream]).first
  end

  private

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

end
