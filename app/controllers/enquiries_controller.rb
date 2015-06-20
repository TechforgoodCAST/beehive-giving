class EnquiriesController < ApplicationController

  before_filter :load_funder, :load_recipient
  before_filter :load_funder_attribute, only: [:guidance, :apply]

  respond_to :js

  def approach_funder
    @recommendation = Recommendation.where(recipient: @recipient, funder: @funder).first
    @enquiry = Enquiry.where(recipient: @recipient, funder: @funder).first_or_create
    @enquiry.increment!(:approach_funder_count)
  end

  def guidance
    @enquiry = Enquiry.where(recipient: @recipient, funder: @funder).first_or_create
    @enquiry.increment!(:guidance_count)
  end

  def apply
    @enquiry = Enquiry.where(recipient: @recipient, funder: @funder).first_or_create
    @enquiry.increment!(:apply_count)
  end

  private

  def load_funder
    @funder = Funder.find_by_slug(params[:id])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

  def load_funder_attribute
    @funder_attribute = @funder.attributes.where(funding_stream: 'All').first
  end

end
