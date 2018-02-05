FactoryBot.define do
  factory :fund do
    association :geo_area, strategy: :build

    funder
    sequence(:name) { |n| "Awards for All #{n}" }
    description 'Some description of the fund.'
    open_call true
    state 'active'
    currency 'GBP'
    key_criteria '<p>E.g. Local charitable organisations are viewed more favourably than large national organisations.</p><p>Grants can be used for:</p><ul><li>Projects that meet the needs of communities experiencing high levels of deprivation.</li></ul>'
    application_link 'http://www.example.org/'

    geographic_scale_limited false

    restrictions_known true
    priorities_known true

    permitted_org_types [1, 2, 3] # A registered charity, A registered company
    permitted_costs [1, 2] # Capital funding, Revenue funding

    min_amount_awarded_limited true
    min_amount_awarded 5_000
    max_amount_awarded_limited true
    max_amount_awarded 10_000

    min_org_income_limited true
    min_org_income 10_000
    max_org_income_limited true
    max_org_income 250_000

    # TODO: refactor
    factory :fund_simple, class: Fund do
      restrictions_known false
      priorities_known false
      after(:build) do |fund, _evaluator|
        fund.themes = build_list(:theme, 1) unless fund.themes.any?
      end
    end

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
          { "start" => 0, "end" => 49, "segment" => 0, "percent" => 0, "count" => 0 },
          { "start" => 50, "end" => 299, "segment" => 1, "percent" => 0, "count" => 0 },
          { "start" => 300, "end" => 749, "segment" => 2, "percent" => 0, "count" => 0 },
          { "start" => 750, "end" => 1_499, "segment" => 3, "percent" => 0, "count" => 0 },
          { "start" => 1_500, "end" => 3_499, "segment" => 4, "percent" => 0, "count" => 0 },
          { "start" => 3_500, "end" => 7_499, "segment" => 5, "percent" => 0.1, "count" => 5 },
          { "start" => 7_500, "end" => 12_499, "segment" => 6, "percent" => 0.2, "count" => 10 },
          { "start" => 12_500, "end" => 17_499, "segment" => 7, "percent" => 0.3, "count" => 15 },
          { "start" => 17_500, "end" => 27_499, "segment" => 8, "percent" => 0.34, "count" => 17 },
          { "start" => 27_500, "end" => 34_999, "segment" => 9, "percent" => 0, "count" => 0 },
          { "start" => 35_000, "end" => 44_999, "segment" => 10, "percent" => 0.06, "count" => 3 },
          { "start" => 45_000, "end" => 74_999, "segment" => 11, "percent" => 0, "count" => 0 },
          { "start" => 75_000, "end" => 299_999, "segment" => 12, "percent" => 0, "count" => 0 },
          { "start" => 300_000, "end" => 5_249_999, "segment" => 13, "percent" => 0, "count" => 0 },
          { "start" => 5_250_000, "end" => 9_007_199_254_740_991, "segment" => 14, "percent" => 0, "count" => 0 }
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

      grant_examples do
        [
          {"id": "360G-phf-30692", "title": "Core funding for expansion of Xplode's youth-led model", "amount": "60000.0", "currency": "GBP", "recipient": "Xplode Magazine", "award_date": "2016-07-18"},
          {"id": "360G-phf-30793", "title": "Widening the reach of Kidscapes transformative anti-bullyinh programme in the North West.", "amount": "60000.0", "currency": "GBP", "recipient": "Kidscape Campaign For Children's Safety", "award_date": "2016-07-18"},
          {"id": "360G-phf-29538", "title": "Funding toward the Co-Director's salary", "amount": "60000.0", "currency": "GBP", "recipient": "URPotential", "award_date": "2015-12-14"},
          {"id": "360G-phf-30337", "title": "Youth led action for stop and search reform.", "amount": "50000.0", "currency": "GBP", "recipient": "Release", "award_date": "2016-04-19"},
          {"id": "360G-phf-29797", "title": "Support as Project Oracle transitions to becoming an independent charity and expands the project's reach and impact", "amount": "60000.0", "currency": "GBP", "recipient": "Project Oracle", "award_date": "2016-04-19"}
        ]
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

  factory :fundstub, class: Fund do
    funder
    sequence(:name) { |n| "Foundation Main Fund Stub #{n}" }
    description 'Some description of the fund stub.'
    state 'stub'
  end
end
