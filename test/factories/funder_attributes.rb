# TODO: deprecated
FactoryGirl.define do

  factory :approval_months, class: ApprovalMonth do
    sequence(:month, (0..11).cycle) { |n| %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[n] }
  end

  factory :funder_attribute do
    funder
    year Date.today.year
    application_count nil
    enquiry_count nil
    funding_stream 'All'
    description 'description'
    approval_months { FactoryGirl.create_list(:approval_months, 1) }
    funded_average_age(&:funded_organisation_age)
    soft_restrictions 'Soft restrictions'
    application_details 'Application details'
    application_link 'www.example.com'
    funded_age_temp 365
    funded_income_temp 10_000
    after(:build) do |a|
      a.grant_count_from_grants
      a.funding_size_and_duration_from_grants
      a.funded_organisation_income_and_staff
    end
  end

  factory :funder_attribute_no_grants, class: FunderAttribute do
    year Date.today.year
    association :funder, factory: :funder
    countries { FactoryGirl.create_list(:country, 2) }
    funding_stream 'All'
    description 'description'
    soft_restrictions 'Soft restrictions'
    application_details 'Application details'
  end

end
