FactoryGirl.define do
  factory :funding_types, class: FundingType do
    label { ['Unrestricted', 'Restricted'].sample }
  end
  factory :approval_months, class: ApprovalMonth do
    sequence(:month, (0..11).cycle) { |n| ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][n] }
  end

  factory :funder_attribute, class: FunderAttribute do
    year 2014
    association :funder, :factory => :funder
    countries { FactoryGirl.create_list(:country, 2) }
    districts { FactoryGirl.create_list(:district, 2) }
    after(:build) { |a| a.grant_count_from_grants }
    application_count nil
    enquiry_count nil
    after(:build) { |a| a.funding_size_and_duration_from_grants }
    funding_types { FactoryGirl.create_list(:funding_types, 2) }
    funding_stream "All"
    approval_months { FactoryGirl.create_list(:approval_months, 2) }
    funded_average_age { |a| a.funded_organisation_age }
    # funded_average_income 1234
    # funded_average_paid_staff 1234
    after(:build) { |a| a.funded_organisation_income_and_staff }
    soft_restrictions "Soft restrictions"
    application_details "Application details"
    application_link "www.example.com"
  end

  factory :funder_attribute_no_grants, class: FunderAttribute do
    year 2014
    association :funder, :factory => :funder
    countries { FactoryGirl.create_list(:country, 2) }
    funding_stream "All"
    soft_restrictions "Soft restrictions"
    application_details "Application details"
  end

end
