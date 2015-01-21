FactoryGirl.define do
  factory :profile do
    year 2014
    gender 'All genders'
    currency 'GBP'
    goods_services 'both'
    who_pays 'both'
    who_buys 'both'
    min_age 14
    max_age 28
    income 0
    expenditure 0
    volunteer_count 0
    staff_count 0
    job_role_count 0
    department_count 0
    goods_count 0
    units_count 0
    services_count 0
    beneficiaries_count 0
    #Error?
    # after(:create) do |profile|
    #   profile.beneficiaries = ['option1', 'option2']
    # end
  end
end
