FactoryGirl.define do
  factory :funding_types, class: FundingType do
    label { ['Unrestricted', 'Restricted'].sample }
  end
  factory :approval_months, class: ApprovalMonth do
    sequence(:month, (0..11).cycle) { |n| ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][n] }
  end

  factory :funder_attribute, class: FunderAttribute do
    year Date.today.year
    association :funder, :factory => :funder
    countries { FactoryGirl.create_list(:country, 2) }
    districts { FactoryGirl.create_list(:district, 2) }
    application_count nil
    enquiry_count nil
    funding_types { FactoryGirl.create_list(:funding_types, 2) }
    funding_stream 'All'
    description 'description'
    approval_months { FactoryGirl.create_list(:approval_months, 1) }
    funded_average_age { |a| a.funded_organisation_age }
    soft_restrictions 'Soft restrictions'
    application_details 'Application details'
    application_link 'www.example.com'
    age_groups { FactoryGirl.create_list(:age_group, 8) }
    beneficiaries { FactoryGirl.create_list(:beneficiary, 2) }
    funded_age_temp 365
    funded_income_temp 10000
    after(:build) do |a|
      a.grant_count_from_grants
      a.funding_size_and_duration_from_grants
      a.funded_organisation_income_and_staff
    end
  end

  factory :funder_attribute_no_grants, class: FunderAttribute do
    year Date.today.year
    association :funder, :factory => :funder
    countries { FactoryGirl.create_list(:country, 2) }
    funding_stream 'All'
    description 'description'
    soft_restrictions 'Soft restrictions'
    application_details 'Application details'
  end

end
