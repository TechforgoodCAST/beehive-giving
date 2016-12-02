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
    application_link 'http://www.example.org'
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
      period_end { Date.today }

      # Overview
      grant_count 250
      recipient_count 225

      amount_awarded_sum 7089684
      amount_awarded_mean 120164.14
      amount_awarded_median 90000
      amount_awarded_min 5000
      amount_awarded_max 1500000
      amount_awarded_distribution do
        [
          { "segment": 0, "start": 0,     "end": 4999,  "count": 3  },
          { "segment": 1, "start": 5000,  "end": 9999,  "count": 87 },
          { "segment": 2, "start": 10000, "end": 14999, "count": 10 }
        ]
      end

      duration_awarded_months_mean 11.789
      duration_awarded_months_median 10.789
      duration_awarded_months_min 6
      duration_awarded_months_max 12
      duration_awarded_months_distribution do
        [
          { "segment": 4, "quarter": "Oct - Dec", "range": "10 - 12 months", "count": 2 },
          { "segment": 12, "quarter": "Oct - Dec", "range": "34 - 36 months", "count": 2 }
        ]
      end
      award_month_distribution do
        [
          { "month": 1, "count": 24, "percent": 0.40, "amount": 3732076 },
          { "month": 2, "count": 24, "percent": 0.40, "amount": 2297650 },
          { "month": 3, "count": 11, "percent": 0.20, "amount": 1059958 }
        ]
      end

      # Recipient
      org_type_distribution do
        [
          { "position": 1, "label": "A registered charity",                    "percent": 0.755 },
          { "position": 2, "label": "A registered charity & company",          "percent": 0.215 },
          { "position": 3, "label": "Another type of organisation",            "percent": 0.03 },
          { "position": 4, "label": "An unregistered organisation OR project", "percent": 0 },
          { "position": 5, "label": "A registered company",                    "percent": 0 },
          { "position": 6, "label": "An individual",                           "percent": 0 }
        ]
      end
      operating_for_distribution do
        [
          { "position": 1, "label": "4 years or more",     "percent": 0.755 },
          { "position": 2, "label": "Less than 3 years",   "percent": 0.215 },
          { "position": 3, "label": "Less than 12 months", "percent": 0.03 },
          { "position": 4, "label": "Yet to start",        "percent": 0 },
          { "position": 4, "label": "Unknown",             "percent": 0 }
        ]
      end
      income_distribution do
        [
          { "position": 1, "label": "£100k - £1m",    "percent": 0.755 },
          { "position": 2, "label": "£10k - £100k",   "percent": 0.2 },
          { "position": 3, "label": "£1m - £10m",     "percent": 0.045 },
          { "position": 4, "label": "Less than £10k", "percent": 0 },
          { "position": 5, "label": "£10m+",          "percent": 0 },
          { "position": 6, "label": "Unknown+",       "percent": 0 }
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
          { "position": 9, "label": "Unknown+",  "percent": 0 }
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
          { "position": 9, "label": "Unknown+",  "percent": 0 }
        ]
      end

      # Beneficiary
      gender_distribution do
        [
          { "position": 1, "label": "All genders", "percent": 0.922 },
          { "position": 2, "label": "Female",      "percent": 0.068 },
          { "position": 3, "label": "Male",        "percent": 0.01 },
          { "position": 4, "label": "Transgender", "percent": 0 },
          { "position": 5, "label": "Other",       "percent": 0 },
          { "position": 6, "label": "N/A",         "percent": 0 }
        ]
      end
      age_group_distribution do
        [
          { "label": "Adolescents (12-19 years)", "age_from": 12, "age_to": 19, "count": 26, "percent": 0.4406779661016949, "position": 1 },
          { "label": "Children (4-11 years)", "age_from": 4, "age_to": 11, "count": 24, "percent": 0.4067796610169492, "position": 2 },
          { "label": "Mature adults (51-80 years)", "age_from": 51, "age_to": 80, "count": 24, "percent": 0.4067796610169492, "position": 3 },
          { "label": "Young adults (20-35 years)", "age_from": 20, "age_to": 35, "count": 24, "percent": 0.4067796610169492, "position": 4 },
          { "label": "Older adults (80+)", "age_from": 80, "age_to": 150, "count": 22, "percent": 0.3728813559322034, "position": 5 },
          { "label": "Adults (36-50 years)", "age_from": 36, "age_to": 50, "count": 21, "percent": 0.3559322033898305, "position": 6 },
          { "label": "Infants (0-3 years)", "age_from": 0, "age_to": 3, "count": 19, "percent": 0.3220338983050847, "position": 7 },
          { "label": "All ages", "age_from": 0, "age_to": 150, "count": 18, "percent": 0.3050847457627119, "position": 8 }
        ]
      end
      beneficiary_distribution do
        [
          { "label": "This organisation", "group": "Other", "sort": "organisation", "count": 37, "percent": 0.6271186440677966, "position": 1 },
          { "label": "The general public", "group": "People", "sort": "public", "count": 12, "percent": 0.2033898305084746, "position": 2 },
          { "label": "Climate and the environment", "group": "Other", "sort": "environment", "count": 10, "percent": 0.1694915254237288, "position": 3 },
          { "label": "Other organisations", "group": "Other", "sort": "organisations", "count": 10, "percent": 0.1694915254237288, "position": 4 },
          { "label": "In education", "group": "People", "sort": "education", "count": 7, "percent": 0.11864406779661017, "position": 5 },
          { "label": "With family/relationship challenges", "group": "People", "sort": "relationship", "count": 7, "percent": 0.11864406779661017, "position": 6 },
          { "label": "Affected or involved with crime", "group": "People", "sort": "crime", "count": 7, "percent": 0.11864406779661017, "position": 7 },
          { "label": "With disabilities", "group": "People", "sort": "disabilities", "count": 7, "percent": 0.11864406779661017, "position": 8 },
          { "label": "Who are unemployed", "group": "People", "sort": "unemployed", "count": 6, "percent": 0.1016949152542373, "position": 9 },
          { "label": "From a specific ethnic background", "group": "People", "sort": "ethnic", "count": 6, "percent": 0.1016949152542373, "position": 10 },
          { "label": "With mental diseases or disorders", "group": "People", "sort": "mental", "count": 5, "percent": 0.0847457627118644, "position": 11 },
          { "label": "At risk of sexual exploitation, trafficking, forced labour, or servitude", "group": "People", "sort": "exploitation", "count": 4, "percent": 0.06779661016949153, "position": 12 },
          { "label": "Facing income poverty", "group": "People", "sort": "poverty", "count": 3, "percent": 0.05084745762711865, "position": 13 },
          { "label": "With housing/shelter challenges", "group": "People", "sort": "housing", "count": 2, "percent": 0.03389830508474576, "position": 14 },
          { "label": "With specific religious/spiritual beliefs", "group": "People", "sort": "religious", "count": 1, "percent": 0.01694915254237288, "position": 15 },
          { "label": "Who are refugees and asylum seekers", "group": "People", "sort": "refugees", "count": 1, "percent": 0.01694915254237288, "position": 16 },
          { "label": "With a specific sexual orientation", "group": "People", "sort": "orientation", "count": 1, "percent": 0.01694915254237288, "position": 17 },
          { "label": "With physical diseases or disorders", "group": "People", "sort": "physical", "count": 1, "percent": 0.01694915254237288, "position": 18 },
          { "label": "Animals and wildlife", "group": "Other", "sort": "animals", "count": 0, "percent": 0, "position": 19 },
          { "label": "With food access challenges", "group": "People", "sort": "food", "count": 0, "percent": 0, "position": 20 },
          { "label": "With water/sanitation access challenges", "group": "People", "sort": "water", "count": 0, "percent": 0, "position": 21 },
          { "label": "Affected by disasters", "group": "People", "sort": "disasters", "count": 0, "percent": 0, "position": 22 },
          { "label": "Involved with the armed or rescue services", "group": "People", "sort": "services", "count": 0, "percent": 0, "position": 23 },
          { "label": "In, leaving, or providing care", "group": "People", "sort": "care", "count": 0, "percent": 0, "position": 24 },
          { "label": "Buildings and places", "group": "Other", "sort": "buildings", "count": 0, "percent": 0, "position": 25 }
        ]
      end

      # Location
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
      district_distribution do
        [
          { "name": "England", "count": 14, "percent": 0.75 },
          { "name": "London",  "count": 3,  "percent": 0.25 }
        ]
      end
    end
  end
end
