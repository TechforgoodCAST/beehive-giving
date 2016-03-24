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
    slug 'london'
  end

  factory :beneficiary do
    label 'Other'
    category 'People'
  end

  factory :beneficiary_other, class: Beneficiary do
    label 'Other'
    category 'Other'
  end

  factory :beneficiary_unique, class: Beneficiary do
    label 'Education'
    category 'People'
  end

  factory :age_group do
    sequence(:label, (0..7).cycle) { |n| ['All ages', 'Infants (0-3 years)', 'Children (4-11 years)', 'Adolescents (12-19 years)', 'Young adults (20-35 years)', 'Adults (36-50 years)', 'Mature adults (51-80 years)', 'Older adults (80+)'][n] }
  end

  factory :implementor do
    label 'Something'
  end

  factory :implementation do
    label 'Something'
  end

  factory :profile do
    year Date.today.year
    gender 'All genders'
    volunteer_count 1
    staff_count 1
    trustee_count 3
    does_sell true
    income 1
    expenditure 1
    income_actual true
    expenditure_actual true
    affect_people true
    affect_other false

    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
    beneficiaries {FactoryGirl.create_list(:beneficiary, 2)}
    age_groups {FactoryGirl.create_list(:age_group, 8)}
    implementors {FactoryGirl.create_list(:implementor, 2)}
    implementations {FactoryGirl.create_list(:implementation, 2)}
  end

  factory :profiles, class: Profile do
    sequence(:year) { |n| "201#{n+1}" }
    gender 'All genders'
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
    affect_people true
    affect_other false

    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
    beneficiaries {FactoryGirl.create_list(:beneficiary, 1)}
    age_groups {FactoryGirl.create_list(:age_group, 8)}
    implementors {FactoryGirl.create_list(:implementor, 2)}
    implementations {FactoryGirl.create_list(:implementation, 2)}
  end

  factory :incomplete_profile, class: Profile do
    year Date.today.year
    gender 'All genders'
    affect_people true
    affect_other false
    beneficiaries {FactoryGirl.create_list(:beneficiary, 2)}
    age_groups {FactoryGirl.create_list(:age_group, 8)}
  end

  factory :beneficiary_other_profile, class: Profile do
    year Date.today.year
    gender 'All genders'
    affect_people true
    affect_other false
    beneficiaries {FactoryGirl.create_list(:beneficiary_other, 2)}
    age_groups {FactoryGirl.create_list(:age_group, 8)}
  end

end
