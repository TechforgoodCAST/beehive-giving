FactoryGirl.define do
  factory :beneficiary do
    label 'Other'
  end

  factory :country do
    name "Other"
    alpha2 "Other"
  end

  factory :district do
    association :country, :factory => :country
    label 'Other'
    district 'Other'
    subdivision 'Other'
  end

  factory :implementation do
    label 'Something'
  end

  factory :implementor do
    label 'Something'
  end

  factory :profile do
    year 2014
    gender 'All genders'
    min_age 14
    max_age 28
    volunteer_count 1
    staff_count 1
    does_sell true
    beneficiaries_count 1
    beneficiaries_count_actual true
    income 1
    expenditure 1
    income_actual true
    expenditure_actual true

    before(:create) do |object|
      object.update :countries => FactoryGirl.create_list(:country, 2)
      object.update :beneficiaries => FactoryGirl.create_list(:beneficiary, 2)
      object.update :districts => FactoryGirl.create_list(:district, 2)
      object.update :implementors => FactoryGirl.create_list(:implementor, 2)
      object.update :implementations => FactoryGirl.create_list(:implementation, 2)
    end
  end
end
