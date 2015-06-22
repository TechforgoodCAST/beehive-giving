FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    job_role 'CEO'
    user_email 'john@organisation.org'
    password 'password123'
    password_confirmation 'password123'
    role 'User'
    agree_to_terms true
  end
end
