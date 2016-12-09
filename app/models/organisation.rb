class Organisation < ActiveRecord::Base
  ORG_TYPE = [
    ['Myself OR another individual', -1],
    ['An unregistered organisation OR project', 0],
    ['A registered charity', 1],
    ['A registered company', 2],
    ['A registered charity & company', 3],
    ['Another type of organisation', 4]
  ].freeze
  OPERATING_FOR = [
    ['Yet to start', 0],
    ['Less than 12 months', 1],
    ['Less than 3 years', 2],
    ['4 years or more', 3]
  ].freeze
  INCOME = [
    ['Less than £10k', 0],
    ['£10k - £100k', 1],
    ['£100k - £1m', 2],
    ['£1m - £10m', 3],
    ['£10m+', 4]
  ].freeze
  EMPLOYEES = [
    ['None', 0],
    ['1 - 5', 1],
    ['6 - 25', 2],
    ['26 - 50', 3],
    ['51 - 100', 4],
    ['101 - 250', 5],
    ['251 - 500', 6],
    ['500+', 7]
  ].freeze

  has_one :subscription, dependent: :destroy
  has_many :users, dependent: :destroy

  has_many :profiles, dependent: :destroy # TODO: deprecated

  geocoded_by :search_address
  after_validation :geocode,
                   if: :street_address_changed?,
                   unless: ->(o) { o.country != 'GB' }

  attr_accessor :skip_validation

  validates :income, :employees, :volunteers,
            presence: true, numericality: { greater_than_or_equal_to: 0 },
            unless: :skip_validation

  validates :income, inclusion: { in: 0..4 },
                     unless: :skip_validation

  validates :employees, :volunteers, inclusion: { in: 0..7 },
                                     unless: :skip_validation

  validates :org_type, :name, :status, :country, :operating_for,
            presence: true, unless: :skip_validation

  validates :org_type,
            inclusion: { in: 0..4, message: 'please select a valid option' },
            unless: :skip_validation

  validates :operating_for,
            inclusion: { in: 0..3, message: 'please select a valid option' },
            unless: :skip_validation

  validates :street_address,
            presence: true,
            if: proc { |o| o.org_type.zero? || o.org_type == 4 },
            unless: :skip_validation
  validates :charity_number,
            presence: true,
            if: proc { |o| o.org_type == 1 || o.org_type == 3 },
            unless: :skip_validation
  validates :company_number,
            presence: true,
            if: proc { |o| o.org_type == 2 || o.org_type == 3 },
            unless: :skip_validation

  validates :charity_number,
            uniqueness: { on: :create, scope: :company_number },
            allow_nil: true, allow_blank: true
  validates :company_number,
            uniqueness: { on: :create, scope: :charity_number },
            allow_nil: true, allow_blank: true

  validates :website, format: {
    with: URI.regexp(%w(http https)),
    message: 'enter a valid website address e.g. http://www.example.com'
  }, if: :website?

  validates :slug, uniqueness: true, presence: true

  validates :postal_code,
            presence: true,
            if: proc { |o| o.charity_name.present? || o.company_name.present? },
            unless: :skip_validation

  before_validation :set_slug, unless: :slug
  before_validation :clear_registration_numbers_if_unregistered
  after_create :create_subscription

  def name=(s)
    self[:name] = s.sub(s.first, s.first.upcase)
  end

  def search_address
    if postal_code.present?
      [postal_code, country].join(', ')
    elsif street_address.present?
      [street_address, country].join(', ')
    end
  end

  def to_param
    slug
  end

  def set_slug
    self.slug = generate_slug
  end

  def generate_slug(n = 1)
    return nil unless name
    candidate = name.downcase.gsub(/[^a-z0-9]+/, '-')
    candidate += "-#{n}" if n > 1
    return candidate unless Organisation.find_by(slug: candidate)
    generate_slug(n + 1)
  end

  def send_authorisation_email(user_to_authorise)
    UserMailer.request_access(self, user_to_authorise).deliver_now
  end

  def charity_commission_url
    'http://beta.charitycommission.gov.uk/charity-details/?regid=' +
      CGI.escape(charity_number) + '&subid=0'
  end

  def companies_house_url
    "https://beta.companieshouse.gov.uk/company/#{CGI.escape(company_number)}"
  end

  def scrape_charity_data
    require 'open-uri'
    response = begin
                 Nokogiri::HTML(open(charity_commission_url, open_timeout: 3))
               rescue
                 nil
               end
    if response
      # refactor
      company_no_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_TabContainer1_tpOverview_plCompanyNumber')
      name_scrape = response.at_css('h1')
      address_scrape = response.at_css('#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_TabContainer1_tpOverview_plContact .detail-33+ .detail-33 .detail-panel-wrap')
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

      if company_no_scrape.present?
        self.company_number = company_no_scrape
                              .text
                              .strip.sub(/Company no. 0|Company no. /, '0')
      end

      self.name = name_scrape.text if name_scrape.present?
      self.charity_name = name_scrape.text if name_scrape.present?

      if website_scrape.present?
        self.website = website_scrape.text if
          website_scrape.text.match(URI.regexp(%w(http https)))
      end
      self.country = 'GB' if name_scrape.present?

      self.postal_code = address_scrape.text.split(',').last.strip if
                           address_scrape.present?
      self.contact_email = email_scrape.text if email_scrape.present?
      self.charity_status = status_scrape.text.tr('-', ' ').capitalize if
                              status_scrape.present?
      self.charity_status = out_of_date_scrape.text.tr('-', ' ').capitalize if
                              out_of_date_scrape.present?
      if year_ending_scrape.present? && year_ending_scrape.include?('Data')
        self.charity_year_ending = year_ending_scrape
                                   .text
                                   .gsub('Data for financial year ending ', '')
                                   .to_date
      end
      if days_overdue_scrape.present?
        self.charity_days_overdue = days_overdue_scrape
                                    .text.gsub('Documents ', '')
                                    .gsub(' days overdue', '')
      end
      if income_scrape.present?
        self.charity_income = income_scrape
                              .text.sub('£', '')
                              .to_f * financials_multiplier(income_scrape)
      end
      if spending_scrape.present?
        self.charity_spending = spending_scrape
                                .text.sub('£', '')
                                .to_f * financials_multiplier(spending_scrape)
      end
      self.charity_trustees = trustee_scrape.text if trustee_scrape.present?
      self.charity_employees = employee_scrape.text if employee_scrape.present?
      self.charity_volunteers = volunteer_scrape.text if
                                  volunteer_scrape.present?
      self.charity_recent_accounts_link = link_scrape['href'] if
                                            link_scrape.present?

      if income_scrape.present?
        income_select(income_scrape.text.sub('£', '')
        .to_f * financials_multiplier(income_scrape))
      end
      staff_select('employees', employee_scrape.text) if
        charity_employees.present?
      staff_select('volunteers', volunteer_scrape.text) if
        charity_volunteers.present?

      if company_no_scrape.present?
        self.org_type = 3
        scrape_company_data
      else
        self.company_number = nil
      end
      true
    else
      false
    end
  end

  def financials_multiplier(scrape)
    return unless scrape.present?
    case scrape.text.last
    when 'K'
      1000
    when 'M'
      1_000_000
    end
  end

  def income_select(income)
    self.income = if income < 10_000
                    0
                  elsif income >= 10_000 && income < 100_000
                    1
                  elsif income >= 100_000 && income < 1_000_000
                    2
                  elsif income >= 1_000_000 && income < 10_000_000
                    3
                  elsif income >= 10_000_000
                    4
                  end
  end

  def staff_select(field_name, count)
    count = count.to_i
    self[field_name] = if count.zero?
                         0
                       elsif count >= 1 && count <= 5
                         1
                       elsif count >= 6 && count <= 25
                         2
                       elsif count >= 26 && count <= 50
                         3
                       elsif count >= 51 && count <= 100
                         4
                       elsif count >= 101 && count <= 250
                         5
                       elsif count >= 251 && count <= 500
                         6
                       elsif count > 500
                         7
                       end
  end

  def scrape_company_data
    require 'open-uri'
    response = begin
                 Nokogiri::HTML(open(companies_house_url))
               rescue
                 nil
               end
    if response
      self.name = response.at_css('#company-name').text.downcase.titleize unless charity_number.present?
      self.country = 'GB' if response.at_css('#company-name')

      self.postal_code = response.at_css('.js-tabs+ dl .data').text.split(',').last.strip unless postal_code.present?
      self.company_name = response.at_css('#company-name').text.downcase.titleize
      self.company_status = response.at_css('#company-status').text
      self.company_type = response.at_css('#company-type').text
      self.company_incorporated_date = response.at_css('#company-creation-date').text
      self.company_last_accounts_date = response.at_css('.column-half:nth-child(1) p+ p strong').text if
        response.at_css('.column-half:nth-child(1) p+ p strong').present?
      self.company_next_accounts_date = response.at_css('.column-half:nth-child(1) .heading-medium+ p strong:nth-child(1)').text if
        response.at_css('.column-half:nth-child(1) .heading-medium+ p strong:nth-child(1)')
      self.company_accounts_due_date = response.at_css('.column-half:nth-child(1) br+ strong').text if response.at_css('.column-half:nth-child(1) br+ strong')
      self.company_last_annual_return_date = response.at_css('.column-half+ .column-half p+ p strong').text if
        response.at_css('.column-half+ .column-half p+ p strong').present?
      self.company_next_annual_return_date = response.at_css('.column-half+ .column-half .heading-medium+ p strong:nth-child(1)').text if
        response.at_css('.column-half+ .column-half .heading-medium+ p strong:nth-child(1)')
      self.company_annual_return_due_date = response.at_css('.column-half+ .column-half br+ strong').text if
        response.at_css('.column-half+ .column-half br+ strong')
      sic_array = []
      10.times do |i|
        sic_array << response.at_css("#sic#{i}").text.strip if response.at_css("#sic#{i}").present?
      end
      self.company_sic = sic_array

      self.registered_on = company_incorporated_date

      set_registered_on_if_scraped if company_incorporated_date

      true
    else
      false
    end
  end

  def set_registered_on_if_scraped
    age = ((Time.zone.today - company_incorporated_date).to_f / 365)
    if age <= 1
      self.operating_for = 1
    elsif age > 1 && age <= 3
      self.operating_for = 2
    elsif age > 3
      self.operating_for = 3
    end
  end

  def create_subscription
    Subscription.create(organisation_id: id) if subscription.nil?
  end

  private

    def street_address_changed?
      street_address.present? ||
        (postal_code.present? && postal_code_changed?)
    end

    def clear_registration_numbers_if_unregistered
      return unless org_type.zero? || org_type == 4
      self.charity_number = nil
      self.company_number = nil
    end
end
