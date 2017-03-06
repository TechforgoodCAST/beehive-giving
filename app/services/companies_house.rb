class CompaniesHouse
  require 'net/http'

  def initialize(company_number)
    uri = URI(
      "http://data.companieshouse.gov.uk/doc/company/#{company_number}.json"
    )
    Net::HTTP.get_response(uri) do |http|
      return false unless http.response.content_type == 'application/json'
      @res = JSON.parse(http.response.body)
    end
  end

  def lookup(org)
    if @res
      data = @res['primaryTopic']

      org.name                       = data['CompanyName'].titleize unless org.charity_number.present?
      org.country                    = { 'United Kingdom' => 'GB' }[data['CountryOfOrigin']]
      org.postal_code                = data['RegAddress'].try(:[], 'Postcode') unless org.postal_code.present?
      org.company_name               = data['CompanyName'].titleize
      org.company_status             = data['CompanyStatus']
      org.company_type               = data['CompanyCategory']
      org.company_incorporated_date  = data['IncorporationDate']
      org.company_last_accounts_date = data['Accounts'].try(:[], 'LastMadeUpDate')
      org.company_next_accounts_date = data['Accounts'].try(:[], 'NextDueDate')
      org.company_next_returns_date  = data['Returns'].try(:[], 'LastMadeUpDate')
      org.company_last_returns_date  = data['Returns'].try(:[], 'NextDueDate')
      org.company_sic                = data['SICCodes'].try(:[], 'SicText')

      org.registered_on = data['IncorporationDate']
      org.operating_for = operating_for_value(data['IncorporationDate'])

      true
    else
      false
    end
  end

  private

    def operating_for_value(date)
      return unless date
      years_old = ((Time.zone.today - date.to_date).to_f / 365)
      if years_old <= 1
        1
      elsif years_old > 1 && years_old <= 3
        2
      elsif years_old > 3
        3
      end
    end
end
