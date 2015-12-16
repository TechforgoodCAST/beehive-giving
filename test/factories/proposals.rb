FactoryGirl.define do
  factory :proposal, class: Proposal do
    association :recipient, factory: :recipient
    title 'Proposal title'
    tagline 'Some tagline summary explaining the proposal, sed do eiusmod sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ada.'
    beneficiaries { FactoryGirl.create_list(:beneficiary, 2) }
    beneficiaries_other_required true
    beneficiaries_other 'Other'
    gender 'All genders'
    min_age 14
    max_age 28
    beneficiaries_count 50
    countries { FactoryGirl.create_list(:country, 2) }
    districts { FactoryGirl.create_list(:district, 2) }
    funding_duration 12
    activity_costs 1000
    activity_costs_estimated true
    people_costs 1000
    people_costs_estimated false
    capital_costs 1000
    capital_costs_estimated false
    other_costs 1000
    other_costs_estimated false
    after(:build) do |object|
      object.total_costs
      object.build_proposal_recommendation
    end
    all_funding_required true
    outcome1 'Outcome 1'
    outcome2 'Outcome 2'
    outcome3 'Outcome 3'
    outcome4 'Outcome 4'
    outcome5 'Outcome 5'
    type_of_support Proposal::TYPE_OF_SUPPORT.sample
  end
end
