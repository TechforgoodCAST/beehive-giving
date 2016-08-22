FactoryGirl.define do
  factory :fund do
    funder
    type_of_fund 'Grant'
    year_of_fund 2016
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

      org_type_distribution do
        [
          { "position": 1, "label": "A registered charity",                    "percentage": 0.755 },
          { "position": 2, "label": "A registered charity & company",          "percentage": 0.215 },
          { "position": 3, "label": "Another type of organisation",            "percentage": 0.03 },
          { "position": 4, "label": "An unregistered organisation OR project", "percentage": 0 },
          { "position": 4, "label": "A registered company",                    "percentage": 0 },
          { "position": 4, "label": "An individual",                           "percentage": 0 }
        ]
      end
      operating_for_distribution do
        [
          { "position": 1, "label": "4 years or more",     "percentage": 0.755 },
          { "position": 2, "label": "Less than 3 years",   "percentage": 0.215 },
          { "position": 3, "label": "Less than 12 months", "percentage": 0.03 },
          { "position": 4, "label": "Yet to start",        "percentage": 0 }
        ]
      end
      income_distribution do
        [
          { "position": 1, "label": "£100k - £1m",    "percentage": 0.755 },
          { "position": 2, "label": "£10k - £100k",   "percentage": 0.2 },
          { "position": 3, "label": "£1m - £10m",     "percentage": 0.045 },
          { "position": 4, "label": "Less than £10k", "percentage": 0 },
          { "position": 5, "label": "£10m+",          "percentage": 0 }
        ]
      end
      employees_distribution do
        [
          { "position": 1, "label": "1 - 5",     "percentage": 0.755 },
          { "position": 2, "label": "6 - 25",    "percentage": 0.2 },
          { "position": 3, "label": "None",      "percentage": 0.045 },
          { "position": 4, "label": "26 - 50",   "percentage": 0 },
          { "position": 5, "label": "51 - 100",  "percentage": 0 },
          { "position": 6, "label": "101 - 250", "percentage": 0 },
          { "position": 7, "label": "251 - 500", "percentage": 0 },
          { "position": 8, "label": "500+",      "percentage": 0 },
        ]
      end
      volunteers_distribution do
        [
          { "position": 1, "label": "1 - 5",     "percentage": 0.755 },
          { "position": 2, "label": "6 - 25",    "percentage": 0.2 },
          { "position": 3, "label": "None",      "percentage": 0.045 },
          { "position": 4, "label": "26 - 50",   "percentage": 0 },
          { "position": 5, "label": "51 - 100",  "percentage": 0 },
          { "position": 6, "label": "101 - 250", "percentage": 0 },
          { "position": 7, "label": "251 - 500", "percentage": 0 },
          { "position": 8, "label": "500+",      "percentage": 0 },
        ]
      end
      geographic_scale_distribution do
        [
          { "position": 1, "label": "One or more regions",     "percentage": 75.5 },
          { "position": 2, "label": "An entire country",       "percentage": 20 },
          { "position": 3, "label": "One or more local areas", "percentage": 4.5 },
          { "position": 4, "label": "Across many countries",   "percentage": 0 }
        ]
      end

      beneficiary_min_age_historic 0
      beneficiary_max_age_historic 150
      gender_distribution do
        [
          { "position": 1, "label": "All genders", "percentage": 0.922 },
          { "position": 2, "label": "Female",      "percentage": 0.068 },
          { "position": 3, "label": "Male",        "percentage": 2 },
          { "position": 4, "label": "Transgender", "percentage": 0 },
          { "position": 5, "label": "Other",       "percentage": 0 }
        ]
      end
    end
  end
end
