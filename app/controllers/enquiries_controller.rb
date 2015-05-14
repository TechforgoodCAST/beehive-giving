class EnquiriesController < ApplicationController

  before_filter :load_funder, :load_recipient

  def new
    if @recipient.eligible?(@funder)
      if @recipient.enquiries.where('funder_id = ?', @funder.id).count > 0
        redirect_to funder_enquiry_feedback_path(@funder, @recipient)
      else
        @enquiry = Enquiry.new
      end
    elsif @recipient.eligibility_count(@funder) < @funder.restrictions.count
      flash[:alert] = "Sorry you're ineligible"
      redirect_to recipient_eligibility_path(@funder)
    else
      flash[:alert] = "Sorry you're ineligible"
      redirect_to recipient_comparison_path(@funder)
    end
  end

  def create
    @enquiry = @recipient.enquiries.new(enquiry_params)

    if @recipient.enquiries.where('funder_id = ?', @funder.id).count > 0
      redirect_to funder_enquiry_feedback_path(@funder, @recipient)
    else
      if @enquiry.save
        redirect_to funder_enquiry_feedback_path(@funder, @recipient)
      else
        render :new
      end
    end
  end

  def feedback
    @enquiry = @recipient.enquiries.where('funder_id = ?', @funder)
  end

  private

  def enquiry_params
    params.require(:enquiry).permit(:funder_id, :new_project, :new_location, :amount_seeking,
    :duration_seeking, country_ids: [], district_ids: [])
  end

  def load_funder
    @funder = Funder.find_by_slug(params[:funder_id])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

end
