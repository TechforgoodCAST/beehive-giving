class Recipient < ApplicationRecord
  include RecipientValidations
  include RegNoValidations
  include OrgTypeValidations

  has_many :answers, as: :category, dependent: :destroy
  accepts_nested_attributes_for :answers

  has_many :attempts
  has_many :assessments
  has_many :countries, -> { distinct }, through: :proposals
  has_many :districts, -> { distinct }, through: :proposals
  has_many :proposals
  has_many :requests
  has_many :users, as: :organisation, dependent: :destroy

  has_one  :subscription, dependent: :destroy

  validates :charity_number,
            uniqueness: { scope: :company_number },
            allow_blank: true
  validates :company_number,
            uniqueness: { scope: :charity_number },
            allow_blank: true
  validates :website, format: {
    with: URI.regexp(%w[http https]),
    message: 'enter a valid website address e.g. http://www.example.com'
  }, if: :website?
  validates :slug, uniqueness: true, presence: true
  validates :postal_code,
            presence: true,
            if: proc { |o| o.charity_name.present? || o.company_name.present? }

  before_validation :set_slug, if: :should_set_slug?
  before_validation :clear_registration_numbers_if_unregistered
  after_validation :geocode,
                   if: :street_address_changed?,
                   unless: ->(o) { o.country != 'GB' }
  before_save :unique_reveals
  after_create :create_subscription

  geocoded_by :search_address

  def name=(s)
    self[:name] = s.sub(s.first, s.first.upcase)
  end

  def charity_number=(s)
    self[:charity_number] = s.presence.try(:strip)
  end

  def company_number=(s)
    self[:company_number] = s.presence.try(:strip)
  end

  def to_param
    slug
  end

  def set_slug
    self.slug = generate_slug(self, name)
  end

  def send_authorisation_email(user_to_authorise)
    UserMailer.request_access(self, user_to_authorise).deliver_now
  end

  def subscribe!
    subscription.update(active: true, expiry_date: 1.years.from_now)
  end

  def unsubscribe!
    subscription.update(active: false)
  end

  def subscribed?
    subscription&.active?
  end

  def transferred? # TODO: refactor
    proposals.where(state: 'transferred').count.positive?
  end

  def incomplete_first_proposal? # TODO: refactor
    proposals.count == 1 && proposals.last.state != 'complete'
  end

  def scrape_org
    case org_type
    when 1
      scrape_charity_data
    when 2
      lookup_company_data
    when 3
      scrape_charity_data
      lookup_company_data
    when 5
      lookup_company_data
    else
      self[:registered_on] = nil
    end
  end

  def find_with_reg_nos
    return false unless [1, 2, 3, 5].include?(self[:org_type])
    self.class.find_by(
      charity_number: charity_number,
      company_number: company_number
    )
  end

  def max_income
    income || INCOME_BANDS[income_band][3]
  end

  def min_income
    income || INCOME_BANDS[income_band][2]
  end

  private

    def create_subscription
      Subscription.create(recipient_id: id, version: 2) if subscription.nil?
    end

    def unique_reveals
      self[:reveals] = self[:reveals].uniq
    end

    def search_address
      if postal_code.present?
        [postal_code, country].join(', ')
      elsif street_address.present?
        [street_address, country].join(', ')
      end
    end

    def should_set_slug?
      slug.blank? || (name.present? && name_changed?)
    end

    def street_address_changed?
      street_address.present? ||
        (postal_code.present? && postal_code_changed?)
    end

    def clear_registration_numbers_if_unregistered
      return unless unregistered_org
      self.charity_number = nil
      self.company_number = nil
    end

    def charity_commission_url
      'http://beta.charitycommission.gov.uk/charity-details/?regid=' +
        CGI.escape(charity_number) + '&subid=0'
    end

    def scrape_charity_data
      require 'open-uri'
      response = begin
                   Nokogiri::HTML(open(charity_commission_url, open_timeout: 3))
                 rescue
                   nil
                 end
      if response && response.at_css('h1') # TODO: test
        # TODO: refactor
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
                                .gsub(/\s+/, '').sub('Companyno.', '')
        end

        self.name = name_scrape.text if name_scrape.present?
        self.charity_name = name_scrape.text if name_scrape.present?

        if website_scrape.present?
          self.website = website_scrape.text if
            website_scrape.text.match(URI.regexp(%w[http https]))
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
          self.charity_income = income_scrape.text.sub('£', '').to_f * financials_multiplier(income_scrape)
        end
        if spending_scrape.present?
          self.charity_spending = spending_scrape.text.sub('£', '').to_f * financials_multiplier(spending_scrape)
        end
        self.charity_trustees = trustee_scrape.text if trustee_scrape.present?
        self.charity_employees = employee_scrape.text if
                                   employee_scrape.present?
        self.charity_volunteers = volunteer_scrape.text if
                                    volunteer_scrape.present?
        self.charity_recent_accounts_link = link_scrape['href'] if
                                              link_scrape.present?

        if income_scrape.present?
          income_select(income_scrape.text.sub('£', '').to_f * financials_multiplier(income_scrape))
        end
        staff_select('employees', charity_employees) if
          charity_employees.present?
        staff_select('volunteers', charity_volunteers) if
          charity_volunteers.present?

        if company_no_scrape.present?
          self.org_type = 3
          lookup_company_data
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
      self.income = income
      self.income_band = INCOME_BANDS.find do |band|
        income >= band[2] && income < band[3]
      end[1]
    end

    def staff_select(field_name, count)
      count = count.to_i
      self[field_name] = EMPLOYEES.find do |band|
        count >= band[2] && count <= band[3]
      end[1]
    end

    def lookup_company_data
      CompaniesHouse.new(company_number).lookup(self)
    end
end
