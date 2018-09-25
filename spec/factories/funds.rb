# TODO: refactor
FactoryBot.define do
  factory :fund do
    association :geo_area, strategy: :build, children: false

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
        fund.restrictions << build_list(:restriction, 2, category: 'Recipient')
        fund.restrictions << build_list(:restriction, 2)
        fund.priorities = build_list(:priority, 2)
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
