class RecipientsController < ApplicationController
  before_filter :check_organisation_ownership_or_funder, :only => [:show]
  before_filter :ensure_logged_in, :load_recipient, :years_ago
  before_filter :load_funder, :only => [:gateway, :unlock_funder, :comparison]
  before_filter :load_feedback, :except => [:unlock_funder, :vote]
  before_filter :funder_attribute, :only => [:gateway, :comparison]

  # def edit
  # end
  #
  # def update
  #   if @recipient.update_attributes(recipient_params)
  #     redirect_to root_path, notice: 'Organisation updated!'
  #   else
  #     render :edit
  #   end
  # end

  def dashboard
    @search = Funder.ransack(params[:q])
    @profile = @recipient.profiles.where('year = ?', 2015).first
  end

  def gateway
    if current_user.feedbacks.count < 1 && @recipient.unlocked_funders.count == 1
      redirect_to new_feedback_path(:redirect_to_funder => @funder)
    else
      redirect_to recipient_comparison_path(@funder) unless @recipient.locked_funder?(@funder)
    end
  end

  def unlock_funder
    @recipient.unlock_funder!(@funder) if @recipient.locked_funder?(@funder)
    redirect_to recipient_comparison_path(@funder)
  end

  def comparison
    redirect_to recipient_comparison_gateway_path(@funder) if @recipient.locked_funder?(@funder)
    @restrictions = @funder.restrictions.uniq
  end

  def vote
    vote = Feature.find_or_initialize_by(recipient_id: params[:recipient_id], funder_id: params[:funder_id])

    vote.update_attributes(
      data_requested: vote.data_requested || params[:data_requested],
      request_amount_awarded: vote.request_amount_awarded || params[:request_amount_awarded],
      request_funding_dates: vote.request_funding_dates || params[:request_funding_dates],
      request_funding_countries: vote.request_funding_countries || params[:request_funding_countries],
      request_grant_count: vote.request_grant_count || params[:request_grant_count],
      request_applications_count: vote.request_applications_count || params[:request_applications_count],
      request_enquiry_count: vote.request_enquiry_count || params[:request_enquiry_count],
      request_funding_types: vote.request_funding_types || params[:request_funding_types],
      request_funding_streams: vote.request_funding_streams || params[:request_funding_streams],
      request_approval_months: vote.request_approval_months || params[:request_approval_months]
    )

    if vote.save
      redirect_to :back, notice: "Requested!"
    else
      redirect_to :back, alert: "Unable to request, perhaps you already did?"
    end
  end

  def show
    @recipient = Recipient.find_by_slug(params[:id])
  end

  def eligibility
    @funder = Funder.find_by_slug(params[:funder_id])
    @restrictions = @funder.restrictions.order(:id).uniq

    # if @recipient.attribute.blank?
    #   redirect_to new_recipient_attribute_path(@recipient, :redirect_to_funder => @funder)
    if @recipient.questions_remaining?(@funder)
      @eligibility =  1.times { @restrictions.each { |r| @recipient.eligibilities.new(restriction_id: r.id) unless @recipient.eligibilities.where('restriction_id = ?', r.id).count > 0 } }
    elsif @recipient.eligible?(@funder)
      redirect_to recipient_comparison_path(@funder)
    else
      flash[:alert] = "Sorry you're ineligible"
      redirect_to recipient_comparison_path(@funder)
    end
  end

  def update_eligibility
    @funder = Funder.find_by_slug(params[:funder_id])
    @restrictions = @funder.restrictions

    if @recipient.update_attributes(eligibility_params)
      if @recipient.eligible?(@funder)
        FunderMailer.eligible_email(@recipient, @funder).deliver
        flash[:notice] = "You're eligible"
        redirect_to recipient_comparison_path(@funder)
      else
        FunderMailer.not_eligible_email(@recipient, @funder).deliver
        flash[:alert] = "Sorry you're ineligible"
        redirect_to recipient_comparison_path(@funder)
      end
    else
      render :eligibility
    end
  end

  def eligibilities
    session[:return_to] ||= request.referer
  end

  def update_eligibilities
    if @recipient.update_attributes(eligibility_params)
      flash[:notice] = "Updated!"
      redirect_to session.delete(:return_to)
    else
      render :eligibilities
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

  def funder_attribute
    @funding_stream = params[:funding_stream] || 'All'

    if @funder.attributes.any?
      @year_of_funding = Funder.find_by_slug(params[:id]).attributes.order(year: :desc).first.year
      @funder_attribute = Funder.find_by_slug(params[:id]).attributes.where('year = ? AND funding_stream = ?', @year_of_funding, @funding_stream).first
      # @funding_years = @funder.attributes.order(year: :desc).pluck(:year).uniq
    end
  end

  def eligibility_params
    params.require(:recipient).permit(:eligibilities_attributes => [:id, :eligible, :restriction_id, :recipient_id])
  end

  # def recipient_params
  #   params.require(:recipient).permit(:name, :contact_number, :website,
  #   :street_address, :city, :region, :postal_code, :country, :charity_number,
  #   :company_number, :founded_on, :registered_on, :mission, :status, :registered)
  # end

end
