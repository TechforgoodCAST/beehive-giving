FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    org_type 0
    sequence(:email) { |n| "email#{n}@organisation.org" }
    password 'password123'
    agree_to_terms true
  end
end
