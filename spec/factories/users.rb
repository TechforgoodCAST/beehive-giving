FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    org_type '0'
    sequence(:user_email) { |n| "email#{n}@organisation.org" }
    password 'password123'
    role 'User'
    agree_to_terms true
  end
end