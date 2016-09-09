FactoryGirl.define do
  factory :fund do
    funder
    type_of_fund 'Grant'
    sequence(:name) { |n| "Awards for All #{n}" }
    description 'Some description of the fund.'
    open_call true
    active true
    currency 'GBP'
    deadlines_known true
    stages_known true

    amount_known true
    amount_min_limited true
    amount_max_limited true
    amount_min 300
    amount_max 10000
    amount_notes 'Notes about amount'

    duration_months_known true
    duration_months_min_limited true
    duration_months_max_limited true
    duration_months_min 6
    duration_months_max 12
    duration_months_notes 'Notes about duration'

    accepts_calls_known true
    accepts_calls true
    contact_number '0123456789'

    geographic_scale { Proposal::AFFECT_GEO.sample[1] }
    geographic_scale_limited true

    restrictions_known true
    outcomes_known true
    decision_makers_known true

    factory :fund_with_open_data, class: Fund do
      open_data true

      period_start { 1.year.ago }
      period_end { 1.day.ago }

      grant_count 250
      recipient_count 225
      amount_mean_historic 7123.1234
      amount_median_historic 5123.1234
      amount_min_historic 300
      amount_max_historic 10000
      duration_months_mean_historic 11.789
      duration_months_median_historic 10.789
      duration_months_min_historic 6
      duration_months_max_historic 12

      amount_awarded_distribution do
        [
          { "segment": 1,  "start": 0, "end": 5000, "count": 3 },
          { "segment": 2,  "start": 5000, "end": 10000, "count": 87 },
          { "segment": 3,  "start": 10000, "end": 15000, "count": 10 }
        ]
      end

      award_month_distribution do
        [
          { "month": 1,  "count": 25, "percent": 0.25, "amount": 25000 },
          { "month": 2,  "count": 0,  "percent": 0,    "amount": 0 },
          { "month": 3,  "count": 0,  "percent": 0,    "amount": 0 },
          { "month": 4,  "count": 25, "percent": 0.25, "amount": 25000 },
          { "month": 5,  "count": 0,  "percent": 0,    "amount": 0 },
          { "month": 6,  "count": 0,  "percent": 0,    "amount": 0 },
          { "month": 7,  "count": 25, "percent": 0.25, "amount": 25000 },
          { "month": 8,  "count": 0,  "percent": 0,    "amount": 0 },
          { "month": 9,  "count": 0,  "percent": 0,    "amount": 0 },
          { "month": 10, "count": 25, "percent": 0.25, "amount": 25000 },
          { "month": 11, "count": 0,  "percent": 0,    "amount": 0 },
          { "month": 12, "count": 0,  "percent": 0,    "amount": 0 }
        ]
      end

      org_type_distribution do
        [
          { "position": 1, "label": "A registered charity",                    "percent": 0.755 },
          { "position": 2, "label": "A registered charity & company",          "percent": 0.215 },
          { "position": 3, "label": "Another type of organisation",            "percent": 0.03 },
          { "position": 4, "label": "An unregistered organisation OR project", "percent": 0 },
          { "position": 4, "label": "A registered company",                    "percent": 0 },
          { "position": 4, "label": "An individual",                           "percent": 0 }
        ]
      end
      operating_for_distribution do
        [
          { "position": 1, "label": "4 years or more",     "percent": 0.755 },
          { "position": 2, "label": "Less than 3 years",   "percent": 0.215 },
          { "position": 3, "label": "Less than 12 months", "percent": 0.03 },
          { "position": 4, "label": "Yet to start",        "percent": 0 }
        ]
      end
      income_distribution do
        [
          { "position": 1, "label": "£100k - £1m",    "percent": 0.755 },
          { "position": 2, "label": "£10k - £100k",   "percent": 0.2 },
          { "position": 3, "label": "£1m - £10m",     "percent": 0.045 },
          { "position": 4, "label": "Less than £10k", "percent": 0 },
          { "position": 5, "label": "£10m+",          "percent": 0 }
        ]
      end
      employees_distribution do
        [
          { "position": 1, "label": "1 - 5",     "percent": 0.755 },
          { "position": 2, "label": "6 - 25",    "percent": 0.2 },
          { "position": 3, "label": "None",      "percent": 0.045 },
          { "position": 4, "label": "26 - 50",   "percent": 0 },
          { "position": 5, "label": "51 - 100",  "percent": 0 },
          { "position": 6, "label": "101 - 250", "percent": 0 },
          { "position": 7, "label": "251 - 500", "percent": 0 },
          { "position": 8, "label": "500+",      "percent": 0 },
        ]
      end
      volunteers_distribution do
        [
          { "position": 1, "label": "1 - 5",     "percent": 0.755 },
          { "position": 2, "label": "6 - 25",    "percent": 0.2 },
          { "position": 3, "label": "None",      "percent": 0.045 },
          { "position": 4, "label": "26 - 50",   "percent": 0 },
          { "position": 5, "label": "51 - 100",  "percent": 0 },
          { "position": 6, "label": "101 - 250", "percent": 0 },
          { "position": 7, "label": "251 - 500", "percent": 0 },
          { "position": 8, "label": "500+",      "percent": 0 },
        ]
      end
      geographic_scale_distribution do
        [
          { "position": 1, "label": "One or more regions",     "percent": 75.5 },
          { "position": 2, "label": "An entire country",       "percent": 20 },
          { "position": 3, "label": "One or more local areas", "percent": 4.5 },
          { "position": 4, "label": "Across many countries",   "percent": 0 }
        ]
      end
      country_distribution do
        [
          { "name": "United Kingdom", "alpha2": "GB", "count": 90, "percent": 0.9 },
          { "name": "Kenya",          "alpha2": "KE", "count": 10, "percent": 0.1 }
        ]
      end

      beneficiary_min_age_historic 0
      beneficiary_max_age_historic 150
      gender_distribution do
        [
          { "position": 1, "label": "All genders", "percent": 0.922 },
          { "position": 2, "label": "Female",      "percent": 0.068 },
          { "position": 3, "label": "Male",        "percent": 2 },
          { "position": 4, "label": "Transgender", "percent": 0 },
          { "position": 5, "label": "Other",       "percent": 0 }
        ]
      end
    end
  end
end
