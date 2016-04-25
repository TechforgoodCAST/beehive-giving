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
    income              10000
    expenditure         10000
    income_actual       true
    expenditure_actual  true
    countries           { FactoryGirl.create_list(:country, 2) }
    districts           { FactoryGirl.create_list(:district, 2) }
    beneficiaries       { FactoryGirl.create_list(:beneficiary, 2) }
    implementors        { FactoryGirl.create_list(:implementor, 2) }
    implementations     { FactoryGirl.create_list(:implementation, 2) }
    state               'complete'

    factory :current_profile do
      affect_people       true
      affect_other        false
      age_groups          { FactoryGirl.create_list(:age_group, 8) }
    end
  end

end
