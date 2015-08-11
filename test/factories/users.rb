FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    user_email 'john@organisation.org'
    password 'password123'
    role 'User'
    agree_to_terms true
  end
end
