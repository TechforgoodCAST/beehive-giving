FactoryGirl.define do
  factory :fund do
    funder
    type_of_fund 'Grant'
    sequence(:name) { |n| "Awards for All #{n}" }
    description 'Some description of the fund.'
    open_call true
    active true
    currency 'GBP'
    key_criteria '<p>E.g. Local charitable organisations are viewed more favourably than large national organisations.</p><p>Grants can be used for:</p><ul><li>Projects that meet the needs of communities experiencing high levels of deprivation.</li></ul>'
    application_link 'http://www.example.org/'

    geographic_scale_limited false

    restrictions_known true

    factory :fund_with_open_data, class: Fund do
      open_data true
      sources do
        { 'https://creativecommons.org/licenses/by/4.0/': 'http://www.example.com' }.to_json
      end
      period_start { 1.year.ago }
      period_end { Time.zone.today }

      # Overview
      grant_count 250

      amount_awarded_distribution do
        [
          { "segment": 0, "start": 0,     "end": 4999,  "count": 3  },
          { "segment": 1, "start": 5000,  "end": 9999,  "count": 87 },
          { "segment": 2, "start": 10_000, "end": 14_999, "count": 10 }
        ].to_json
      end

      award_month_distribution do
        [
          { "month": 1, "count": 24, "percent": 0.40, "amount": 3_732_076 },
          { "month": 2, "count": 24, "percent": 0.40, "amount": 2_297_650 },
          { "month": 3, "count": 11, "percent": 0.20, "amount": 1_059_958 }
        ].to_json
      end

      # Recipient
      org_type_distribution do
        [
          { "position": 1, "label": 'A registered charity',                    "percent": 0.755 },
          { "position": 2, "label": 'A registered charity & company',          "percent": 0.215 },
          { "position": 3, "label": 'Another type of organisation',            "percent": 0.03 },
          { "position": 4, "label": 'An unregistered organisation OR project', "percent": 0 },
          { "position": 5, "label": 'A registered company',                    "percent": 0 },
          { "position": 6, "label": 'An individual',                           "percent": 0 }
        ].to_json
      end

      income_distribution do
        [
          { "position": 1, "label": '£100k - £1m',    "percent": 0.755 },
          { "position": 2, "label": '£10k - £100k',   "percent": 0.2 },
          { "position": 3, "label": '£1m - £10m',     "percent": 0.045 },
          { "position": 4, "label": 'Less than £10k', "percent": 0 },
          { "position": 5, "label": '£10m+',          "percent": 0 },
          { "position": 6, "label": 'Unknown+',       "percent": 0 }
        ].to_json
      end

      # Location
      country_distribution do
        [
          { "name": 'United Kingdom', "alpha2": 'GB', "count": 90, "percent": 0.9 },
          { "name": 'Kenya',          "alpha2": 'KE', "count": 10, "percent": 0.1 }
        ].to_json
      end
    end
  end
end
