FactoryGirl.define do
  factory :district do
    label 'Other'
    district 'Other'
    iso 'Other'
  end

  factory :beneficiary do
    label 'Other'
  end

  factory :country do
    name "Other"
    iso2 "Other"
    iso3 "Other"
    numcode 1
  end

  factory :implementation do
    label 'Something'
  end

  factory :profile do
    year 2014
    gender 'All genders'
    currency 'GBP (£)'
    goods_services 'Products'
    who_pays 'Both'
    min_age 14
    max_age 28
    income 1
    expenditure 1
    volunteer_count 1
    staff_count 1
    job_role_count 1
    department_count 1
    goods_count 1
    units_count 1
    services_count 1
    beneficiaries_count 1
    income_actual true
    expenditure_actual true
    beneficiaries_count_actual true
    units_count_actual true

    before(:create) do |object|
      object.update :districts => FactoryGirl.create_list(:district, 2)
      object.update :implementations => FactoryGirl.create_list(:implementation, 2)
      object.update :countries => FactoryGirl.create_list(:country, 2)
      object.update :beneficiaries => FactoryGirl.create_list(:beneficiary, 2)
    end
  end
end
