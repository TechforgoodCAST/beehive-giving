class SignupRecipientsController < ApplicationController
  before_action :ensure_logged_in, :ensure_not_signed_up

  def new
    @recipient = Recipient.new(org_type:       session[:org_type],
                               charity_number: session[:charity_number],
                               company_number: session[:company_number])

    @scrape_success = @recipient.scrape_org
    return unless @scrape_success
    # refactor
    if @recipient.save
      current_user.update_attribute(:organisation_id, @recipient.id)
      redirect_to new_signup_proposal_path
    elsif (@recipient.errors.added? :charity_number, :taken) ||
          (@recipient.errors.added? :company_number, :taken)
      organisation = @recipient.find_with_reg_nos
      current_user.lock_access_to_organisation(organisation)
      redirect_to unauthorised_path
    end
  end

  def create
    @recipient = Recipient.new(recipient_params)
    session[:org_type] = @recipient.org_type
    session[:charity_number] = @recipient.charity_number
    session[:company_number] = @recipient.company_number

    @scrape_success = @recipient.scrape_org

    if @recipient.save
      reset_session
      current_user.update_attribute(:organisation_id, @recipient.id)
      redirect_to new_signup_proposal_path
    # If company/charity number has already been taken
    elsif (@recipient.errors.added? :charity_number, :taken) ||
          (@recipient.errors.added? :company_number, :taken)
      organisation = @recipient.find_with_reg_nos
      current_user.lock_access_to_organisation(organisation)
      redirect_to unauthorised_path
    else
      render :new
    end
  end

  def edit
    @scrape_success = @recipient.scrape_org
    redirect_to root_path if @recipient.save
  end

  def update
    @recipient.assign_attributes(recipient_params)
    @scrape_success = @recipient.scrape_org
    if @recipient.save
      redirect_to new_signup_proposal_path
    else
      render :edit
    end
  end
end
