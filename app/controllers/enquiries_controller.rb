class EnquiriesController < ApplicationController

  before_filter :load_funder, :load_recipient

  def new
    @enquiry = Enquiry.new
  end

  def create
    @enquiry = Enquiry.new(enquiry_params)
    if @enquiry.valid?
      if params[:commit] == "Preview"
        render :new
      else
        @enquiry.save
        redirect_to root_path
      end
    else
      render :new
    end
  end

  private

  def enquiry_params
    params.require(:enquiry).permit(:new_project, :new_location, :amount_seeking,
    :duration_seeking, country_ids: [], district_ids: [])
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:funder_id])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

end
