class Organisation < ActiveRecord::Base

  before_validation :clear_registration_numbers_if_unregistered

  STATUS = ['Active - currently operational', 'Closed - no longer operational', 'Merged - operating as a different entity']
  ORG_TYPE = [
    ['A new project or unincorporated association', 0],
    ['A registered charity', 1],
    ['A registered company', 2],
    ['A registered charity & company', 3],
    ['Other', 4]
  ]

  has_one :subscription
  has_many :users, dependent: :destroy
  has_many :profiles, dependent: :destroy

  geocoded_by :postal_code
  after_validation :geocode, if: -> (o) { o.postal_code.present? and o.postal_code_changed? }
  geocoded_by :search_address
  after_validation :geocode, if: -> (o) { (o.street_address.present? and o.street_address_changed?) and (o.country.present? and o.country_changed?) }

  attr_accessor :skip_validation

  validates :org_type, :name, :founded_on, :status, :country, presence: true,
    unless: :skip_validation

  validates :org_type, inclusion: { in: 0..4, message: 'please select a valid option' },
    unless: :skip_validation

  validates :street_address, presence: true, if: Proc.new { |o| o.org_type == 0 || o.org_type == 4 },
    unless: :skip_validation
  validates :charity_number, presence: true, if: Proc.new { |o| o.org_type == 1 || o.org_type == 3 },
    unless: :skip_validation
  validates :company_number, presence: true, if: Proc.new { |o| o.org_type == 2 || o.org_type == 3 },
    unless: :skip_validation

  validates :charity_number, uniqueness: { on: [:create], scope: [:company_number] }, allow_nil: true, allow_blank: true
  validates :company_number, uniqueness: { on: [:create], scope: [:charity_number] }, allow_nil: true, allow_blank: true

  validate :founded_on_before_registered_on
  validates :registered_on, presence: true, if: Proc.new { |o| o.org_type != 0 && o.org_type != 4 },
    unless: :skip_validation

  validates :status, inclusion: { in: STATUS },
    unless: :skip_validation

  validates :website, format: {
    with: URI::regexp(%w(http https)),
    message: 'enter a valid website address e.g. http://www.example.com'}, if: :website?

  validates :slug, uniqueness: true, presence: true

  validates :postal_code, presence: true, if: Proc.new { |o| o.charity_name.present? || o.company_name.present? },
    unless: :skip_validation

  before_validation :set_slug, unless: :slug

  def name=(s)
    write_attribute(:name, s.sub(s.first, s.first.upcase))
  end

  def search_address
    [ "#{self.street_address}",
      "#{self.country}"
    ].join(", ")
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
      website_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_TabContainer1_tpOverview_plContact h3+ a')
      email_scrape = response.at_css('br+ a')
      status_scrape = response.at_css('.up-to-date')
      year_ending_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_plHeading h2')
      days_overdue_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_plHeadingUoutOfDate .removed')
      out_of_date_scrape = response.at_css('#global-breadcrumb .out-of-date')
      income_scrape = response.at_css('.detail-33:nth-child(1) .big-money')
      spending_scrape = response.at_css('.detail-33:nth-child(2) .big-money')
      trustee_scrape = response.at_css('#tpPeople li:nth-child(1) .mid-money')
      employee_scrape = response.at_css('#tpPeople li:nth-child(2) .mid-money')
      volunteer_scrape = response.at_css('#tpPeople li:nth-child(3) .mid-money')
      link_scrape = response.at_css('.detail-33:nth-child(2) .doc')

      self.company_number = company_no_scrape.text.strip.sub(/Company no. 0|Company no. /, '0') if company_no_scrape.present?

      self.name = name_scrape.text if name_scrape.present?
      self.charity_name = name_scrape.text if name_scrape.present?

      if website_scrape.present?
        self.website = website_scrape.text if website_scrape.text.match(URI::regexp(%w(http https)))
      end
      self.country = 'GB' if name_scrape.present?

      self.postal_code = address_scrape.text.split(',').last.strip if address_scrape.present?
      self.contact_email = email_scrape.text if email_scrape.present?
      self.charity_status = status_scrape.text.gsub('-',' ').capitalize if status_scrape.present?
      self.charity_status = out_of_date_scrape.text.gsub('-',' ').capitalize if out_of_date_scrape.present?
      self.charity_year_ending = year_ending_scrape.text.gsub('Data for financial year ending ','').to_date if year_ending_scrape.present?
      self.charity_days_overdue = days_overdue_scrape.text.gsub('Documents ','').gsub(' days overdue','') if days_overdue_scrape.present?
      self.charity_income = income_scrape.text.sub('£','').to_f * financials_multiplier(income_scrape) if income_scrape.present?
      self.charity_spending = spending_scrape.text.sub('£','').to_f * financials_multiplier(spending_scrape) if spending_scrape.present?
      self.charity_trustees = trustee_scrape.text if trustee_scrape.present?
      self.charity_employees = employee_scrape.text if employee_scrape.present?
      self.charity_volunteers = volunteer_scrape.text if volunteer_scrape.present?
      self.charity_recent_accounts_link = link_scrape['href'] if link_scrape.present?

      if company_no_scrape.present?
        self.org_type = 3
        get_company_data
      else
        self.company_number = nil
      end

      return true
    else
      return false
    end
  end

  def financials_multiplier(scrape)
    if scrape.present?
      case scrape.text.last
      when 'K'
        return 1000
      when 'M'
        return 1000000
      end
    end
  end

  def get_company_data
    require 'open-uri'
    response = Nokogiri::HTML(open(companies_house_url)) rescue nil
    if response
      self.name = response.at_css('#company-name').text.downcase.titleize unless self.charity_number.present?
      self.country = 'GB' if response.at_css('#company-name')

      self.postal_code = response.at_css('.js-tabs+ dl .data').text.split(',').last.strip unless self.postal_code.present?
      self.company_name = response.at_css('#company-name').text.downcase.titleize
      self.company_status = response.at_css('#company-status').text
      self.company_type = response.at_css('#company-type').text
      self.company_incorporated_date = response.at_css('#company-creation-date').text
      self.company_last_accounts_date = response.at_css('.column-half:nth-child(1) p+ p strong').text if response.at_css('.column-half:nth-child(1) p+ p strong').present?
      self.company_next_accounts_date = response.at_css('.column-half:nth-child(1) .heading-medium+ p strong:nth-child(1)').text if response.at_css('.column-half:nth-child(1) .heading-medium+ p strong:nth-child(1)')
      self.company_accounts_due_date = response.at_css('.column-half:nth-child(1) br+ strong').text if response.at_css('.column-half:nth-child(1) br+ strong')
      self.company_last_annual_return_date = response.at_css('.column-half+ .column-half p+ p strong').text if response.at_css('.column-half+ .column-half p+ p strong').present?
      self.company_next_annual_return_date = response.at_css('.column-half+ .column-half .heading-medium+ p strong:nth-child(1)').text if response.at_css('.column-half+ .column-half .heading-medium+ p strong:nth-child(1)')
      self.company_annual_return_due_date = response.at_css('.column-half+ .column-half br+ strong').text if response.at_css('.column-half+ .column-half br+ strong')
      sic_array = []
      10.times do |i|
        sic_array << response.at_css("#sic#{i}").text.strip if response.at_css("#sic#{i}").present?
      end
      self.company_sic = sic_array

      self.registered_on = self.company_incorporated_date

      return true
    else
      return false
    end
  end

  private

  def founded_on_before_registered_on
    if founded_on.present? and registered_on.present?
      errors.add(:registered_on, "you can't be registered before being founded") if registered_on < founded_on
    end
  end

  def clear_registration_numbers_if_unregistered
    if self.org_type == 0 || self.org_type == 4
      self.charity_number = nil
      self.company_number = nil
      self.registered_on = nil
    end
  end

end
