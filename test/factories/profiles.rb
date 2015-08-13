FactoryGirl.define do
  factory :country, class: Country do
    name "United Kingdom"
    alpha2 "GB"
  end

  factory :district do
    association :country, :factory => :country
    label 'Other'
    district 'London'
    subdivision 'Other'
  end

  factory :beneficiary do
    label 'Other'
  end

  factory :beneficiary_unique, class: Beneficiary do
    label 'Education'
  end

  factory :implementor do
    label 'Something'
  end

  factory :implementation do
    label 'Something'
  end

  factory :profile do
    year 2014
    gender 'All genders'
    min_age 14
    max_age 28
    volunteer_count 1
    staff_count 1
    trustee_count 3
    does_sell true
    beneficiaries_count 1
    beneficiaries_count_actual true
    income 1
    expenditure 1
    income_actual true
    expenditure_actual true

    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
    beneficiaries {FactoryGirl.create_list(:beneficiary, 2)}
    implementors {FactoryGirl.create_list(:implementor, 2)}
    implementations {FactoryGirl.create_list(:implementation, 2)}
  end

  factory :profiles, class: Profile do
    sequence(:year) { |n| "201#{n+1}" }
    gender 'All genders'
    min_age 14
    max_age 28
    volunteer_count 1
    staff_count 1
    trustee_count 3
    does_sell true
    beneficiaries_count 1
    beneficiaries_count_actual true
    income 1
    expenditure 1
    income_actual true
    expenditure_actual true

    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
    beneficiaries {FactoryGirl.create_list(:beneficiary, 2)}
    implementors {FactoryGirl.create_list(:implementor, 2)}
    implementations {FactoryGirl.create_list(:implementation, 2)}
  end
end
