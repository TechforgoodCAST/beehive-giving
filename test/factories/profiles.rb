# TODO: deprecated
FactoryGirl.define do

  factory :implementor do
    label 'Paid staff'
  end

  factory :legacy_profile, class: Profile do
    association         :organisation, factory: :recipient
    year                Date.today.year
    gender              'All genders'
    min_age             14
    max_age             28
    volunteer_count     2
    staff_count         1
    trustee_count       3
    does_sell           true
    income              10_000
    expenditure         10_000
    income_actual       true
    expenditure_actual  true
    implementors        { FactoryGirl.create_list(:implementor, 2) }
    implementations     { FactoryGirl.create_list(:implementation, 2) }
    state               'complete'

    factory :current_profile do
      affect_people       true
      affect_other        false
    end
  end

end
