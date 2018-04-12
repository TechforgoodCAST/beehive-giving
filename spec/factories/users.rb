FactoryBot.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    sequence(:email) { |n| "email#{n}@organisation.org" }
    password 'password123'
    agree_to_terms true
  end
end
