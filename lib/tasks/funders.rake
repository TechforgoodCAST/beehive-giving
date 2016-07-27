namespace :funders do

  # usage: be rake funders:beyondme KEY=locationiq_api_key DESTINATION=/path
  desc 'Export nonprofit data for analysis'
  task beyondme: :environment do
    require 'csv'
    @destination = ENV['DESTINATION']

    def locationiq(lat, lon)
      HTTParty.get("http://osm1.unwiredlabs.com/locationiq/v1/reverse.php?format=json&key=#{ENV['KEY']}&lat=#{lat}&lon=#{lon}")
    end

    query = Recipient.
              joins(:proposals).
              where('employees > ? AND employees < ?', 0, 3).
              where('operating_for > ?', 0).
              where('org_type > ? AND org_type < ?', 0, 4).
              where('country = ?', 'GB')

    query.each_with_index do |org, i|
      sleep(1)
      if org.latitude && org.longitude
        resp = locationiq(org.latitude, org.longitude)
      else
        resp = { "address" => { "city" => "", "county" => "", "state_district" => "" } }
      end
      proposal = org.proposals.first

      data = {
        organisation: org.name,

        org_type: Organisation::ORG_TYPE[org.org_type + 1][0],
        charity_number: org.charity_number,
        company_number: org.company_number,
        company_type: (org.company_type ? org.company_type.strip : ''),

        operating_for: Organisation::OPERATING_FOR[org.operating_for][0],
        income: Organisation::INCOME[org.income][0],
        employees: Organisation::EMPLOYEES[org.employees][0],
        volunteers: Organisation::EMPLOYEES[org.volunteers][0],

        city: resp["address"]["city"] || resp["address"]["town"],
        county: resp["address"]["county"],
        state_district: resp["address"]["state_district"],
        country: org.country,

        age_groups: proposal.age_groups.pluck(:label),
        gender: proposal.gender,
        beneficiaries: proposal.beneficiaries.pluck(:label),

        title: proposal.title,
        description: proposal.tagline,
        amount_seeking_gbp: proposal.total_costs,
        funding_duration_months: proposal.funding_duration
      }

      CSV.open(@destination, 'w') { |csv| csv << data.keys } if i < 1
      CSV.open(@destination, 'a+') { |csv| csv << data.values }
    end

    puts query.count
  end
end
