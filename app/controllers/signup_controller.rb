class SignupController < ApplicationController
  before_filter :ensure_logged_in, except: [:user, :create_user]

  def user
    if logged_in?
      redirect_to root_path
    else
      @user = User.new
    end
  end

  def create_user
    @user = User.new(user_params)
    if @user.save
      cookies[:auth_token] = @user.auth_token
      UserMailer.welcome_email(@user).deliver
      redirect_to find_path if @user.role == 'User'
      redirect_to new_funder_path if @user.role == 'Funder'
    else
      render :user
    end
  end

  def find
    session[:uk_charity] = params[:uk_charity]
    session[:charity_number] = params[:charity_number]

    if session[:uk_charity] == 'false'
      reset_session
      flash[:notice] = 'Please complete the form below'
      redirect_to signup_organisation_path
    elsif session[:uk_charity] == 'true' && session[:charity_number].present?
      require 'open-uri'

      def charity_commission_url(part)
        "http://apps.charitycommission.gov.uk/Showcharity/RegisterOfCharities/#{part}.aspx?RegisteredCharityNumber=#{CGI.escape(params[:charity_number].to_s)}&SubsidiaryNumber=0"
      end

      app_contact = Nokogiri::HTML(open(charity_commission_url('ContactAndTrustees')))
      app_framework = Nokogiri::HTML(open(charity_commission_url('CharityFramework')))

      if app_contact.at_css("#ctl00_RightPanel img") || app_framework.at_css('pre')
        session[:registered] = 'true'
        flash[:alert] = "Uh oh! We couldn't find your organisation, please complete the form below"
      else
        session[:name] = app_contact.at_css('#ctl00_charityStatus_spnCharityName').text.strip.titleize
        session[:mission] = app_framework.at_css('#ctl00_MainContent_ucCharityInfoMessagesDisplay_ucActivities_ucTextAreaInput_txtTextEntry').text.strip.downcase.capitalize
        session[:contact_number] = app_contact.at_css('#ctl00_MainContent_ucDisplay_ucContactDetails_lblPhone').text.strip.gsub('Tel: ', '')
        session[:website] = app_contact.at_css('#ctl00_MainContent_ucDisplay_ucContactDetails_hlWebsite').text.strip.downcase
        session[:street_address] = app_contact.at_css('#ctl00_MainContent_ucDisplay_ucContactDetails_lblAddressLine1').text.strip.downcase.titleize
        session[:city] = app_contact.at_css('#ctl00_MainContent_ucDisplay_ucContactDetails_lblAddressLine2').text.strip.downcase.titleize
        session[:region] = app_contact.at_css('#ctl00_MainContent_ucDisplay_ucContactDetails_lblAddressLine3').text.strip.downcase.titleize
        session[:postal_code] = app_contact.at_css('#ctl00_MainContent_ucDisplay_ucContactDetails_lblAddressLine4').text.strip.downcase.titleize
        session[:country] = 'GB'
        session[:registered] = 'true'
        session[:registered_on] = app_framework.at_css('.DateColumn').text.strip.to_date

        flash[:notice] = 'Found organisaton! Please correct any mistakes'
      end
      redirect_to signup_organisation_path
    else
      reset_session
      render :find
    end
  end

  def organisation
    if current_user.organisation_id
      redirect_to funders_path
    else
      @organisation = Recipient.new(
        name: session[:name],
        mission: session[:mission],
        contact_number: session[:contact_number],
        website: session[:website],
        street_address: session[:street_address],
        city: session[:city],
        region: session[:region],
        postal_code: session[:postal_code],
        country: session[:country],
        registered: session[:registered],
        charity_number: session[:charity_number],
        registered_on: session[:registered_on]
      )
    end
  end

  def create_organisation
    @organisation = Recipient.new(organisation_params)
    if @organisation.save
      current_user.update_attribute(:organisation_id, @organisation.id)
      @organisation.initial_recommendation
      redirect_to funders_path
    else
      render :organisation
    end
  end

  def funder
    @funder = Funder.new
  end

  def create_funder
    @funder = Funder.new(funder_params)
    if @funder.save
      current_user.update_attribute(:organisation_id, @funder.id)
      redirect_to funder_path(current_user.organisation)
    else
      render :funder
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :job_role,
    :user_email, :password, :password_confirmation, :role, :agree_to_terms)
  end

  def organisation_params
    params.require(:recipient).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :country, :charity_number,
    :company_number, :founded_on, :registered_on, :mission, :status, :registered, organisation_ids: [])
  end

  def funder_params
    params.require(:funder).permit(:name, :contact_number, :website,
    :street_address, :city, :region, :postal_code, :country, :charity_number,
    :company_number, :founded_on, :registered_on, :mission, :status, :registered, organisation_ids: [])
  end

  def profile_params
    params.require(:profile).permit(:year, :gender, :currency, :goods_services, :who_pays, :who_buys,
    :min_age, :max_age, :income, :expenditure, :volunteer_count,
    :staff_count, :job_role_count, :department_count, :goods_count,
    :who_pays, :services_count, :beneficiaries_count, :units_count,
    :beneficiaries_count_actual, :units_count_actual, :income_actual, :expenditure_actual,
    beneficiary_ids: [], country_ids: [], district_ids: [], implementation_ids: [])
  end
end
