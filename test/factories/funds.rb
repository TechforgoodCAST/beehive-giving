FactoryGirl.define do
  factory :fund do
    funder
    type_of_fund 'Grant'
    year_of_fund 2016
    name 'Awards for All'
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
  end
end
