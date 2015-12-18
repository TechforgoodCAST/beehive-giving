class Organisation < ActiveRecord::Base
  before_save :clear_registration_numbers_if_not_registered

  STATUS = ['Active - currently operational', 'Closed - no longer operational', 'Merged - operating as a different entity']

  has_one :subscription
  has_many :users, dependent: :destroy
  has_many :profiles, dependent: :destroy

  geocoded_by :postal_code
  after_validation :geocode, if: -> (o) { o.postal_code.present? and o.postal_code? }

  attr_accessor :skip_validation

  validates :name, :founded_on, :status, :country, presence: true,
    unless: :skip_validation

  # validates :registered_on, presence: true, if: :registered?,
  #   unless: :skip_validation
  #
  # validates :registered, :inclusion => { in: [true, false] },
  #   unless: :skip_validation
  #
  # validates :status, inclusion: { in: STATUS },
  #   unless: :skip_validation
  #
  # validates :website, format: {
  #   with: /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\z/,
  #   message: 'enter a valid website address e.g. www.example.com'}, if: :website?
  #
  # validates :slug, uniqueness: true, presence: true
  #
  # validates :charity_number, :company_number, uniqueness: {:on => [:create]}, if: :registered?, allow_nil: true, allow_blank: true
  #
  # validate  :founded_on_before_registered_on, if: :registered?,
  #           unless: Proc.new { |organisation| organisation.founded_on.nil? }
  # validates :charity_number, :company_number,
  #           presence: { message: 'charity OR company number required if legally registered' },
  #           if: Proc.new { |o|
  #             o.registered == true && (o.charity_number.blank? && o.company_number.blank?)
  #           }

  before_validation :set_slug, unless: :slug

  def name=(s)
    write_attribute(:name, s.sub(s.first, s.first.upcase))
  end

  def to_param
    self.slug
  end

  def set_slug
    self.slug = generate_slug
  end

  def generate_slug(n=1)
    return nil unless self.name
    candidate = self.name.downcase.gsub(/[^a-z0-9]+/, '-')
    candidate += "-#{n}" if n > 1
    return candidate unless Organisation.find_by_slug(candidate)
    generate_slug(n+1)
  end

  def charity_commission_url
    "http://beta.charitycommission.gov.uk/charity-details/?regid=#{CGI.escape(charity_number)}&subid=0"
  end

  def companies_house_url
    "https://beta.companieshouse.gov.uk/company/#{CGI.escape(company_number)}"
  end

  def get_charity_data
    require 'open-uri'
    response = Nokogiri::HTML(open(charity_commission_url)) rescue nil
    if response
      # refactor
      company_no_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_TabContainer1_tpOverview_plCompanyNumber')
      name_scrape = response.at_css('h1')
      address_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_TabContainer1_tpOverview_plContact .detail-50+ .detail-50 .detail-panel-wrap')
      website_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_TabContainer1_tpOverview_plContact a')
      email_scrape = response.at_css('br+ a')
      status_scrape = response.at_css('.up-to-date')
      year_ending_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_plHeading h2')
      days_overdue_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_plHeadingUoutOfDate .removed')
      out_of_date_scrape = response.at_css('#global-breadcrumb .out-of-date')
      income_scrape = response.at_css('.detail-33:nth-child(1) .big-money')
      spending_scrape = response.at_css('.detail-33:nth-child(2) .big-money')
      trustee_scrape = response.at_css('li:nth-child(1) .mid-money')
      employee_scrape = response.at_css('li:nth-child(2) .mid-money')
      volunteer_scrape = response.at_css('li:nth-child(3) .mid-money')
      link_scrape = response.at_css('.detail-33:nth-child(2) .doc')

      self.company_number = company_no_scrape.present? ? company_no_scrape.text.strip.gsub('Company no. ','0') : nil
      self.charity_name = name_scrape.text if name_scrape.present?
      self.postal_code = address_scrape.text.split(',').last.strip if address_scrape.present?
      self.website = website_scrape.text.gsub('http://','') if website_scrape.present?
      self.contact_email = email_scrape.text if email_scrape.present?
      self.charity_status = status_scrape.text.gsub('-',' ').capitalize if status_scrape.present?
      self.charity_status = out_of_date_scrape.text.gsub('-',' ').capitalize if out_of_date_scrape.present?
      self.charity_year_ending = year_ending_scrape.text.gsub('Data for financial year ending ','').to_date if year_ending_scrape.present?
      self.charity_days_overdue = days_overdue_scrape.text.gsub('Documents ','').gsub(' days overdue','') if days_overdue_scrape.present?
      self.charity_income = income_scrape.text.gsub('£','').gsub('K','').to_f * 1000 if income_scrape.present?
      self.charity_spending = spending_scrape.text.gsub('£','').gsub('K','').to_f * 1000 if spending_scrape.present?
      self.charity_trustees = trustee_scrape.text if trustee_scrape.present?
      self.charity_employees = employee_scrape.text if employee_scrape.present?
      self.charity_volunteers = volunteer_scrape.text if volunteer_scrape.present?
      self.charity_recent_accounts_link = link_scrape['href'] if link_scrape.present?
    else
      self.company_number = nil
      return false
    end
  end

  def get_company_data
    require 'open-uri'
    response = Nokogiri::HTML(open(companies_house_url)) rescue nil
    if response
      self.company_name = response.at_css('#company-name').text.downcase.titleize
      self.company_status = response.at_css('#company-status').text
      self.company_type = response.at_css('#company-type').text
      self.company_incorporated_date = response.at_css('#company-creation-date').text
      self.company_last_accounts_date = response.at_css('.column-half:nth-child(1) p+ p strong').text
      self.company_next_accounts_date = response.at_css('.column-half:nth-child(1) .heading-medium+ p strong:nth-child(1)').text
      self.company_accounts_due_date = response.at_css('.column-half:nth-child(1) br+ strong').text
      self.company_last_annual_return_date = response.at_css('.column-half+ .column-half p+ p strong').text
      self.company_next_annual_return_date = response.at_css('.column-half+ .column-half .heading-medium+ p strong:nth-child(1)').text
      self.company_annual_return_due_date = response.at_css('.column-half+ .column-half br+ strong').text
      sic_array = []
      10.times do |i|
        sic_array << response.at_css("#sic#{i}").text.strip if response.at_css("#sic#{i}").present?
      end
      self.company_sic = sic_array
    else
      return false
    end
  end

  private

  def founded_on_before_registered_on
    errors.add(:registered_on, "you can't be registered before being founded") if registered_on and registered_on < founded_on
  end

  def clear_registration_numbers_if_not_registered
    # if self.registered? == false
    #   self.registered_on = nil
    #   self.charity_number = nil
    #   self.company_number = nil
    # end
  end

end
