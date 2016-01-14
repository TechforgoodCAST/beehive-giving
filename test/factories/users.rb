FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    org_type '0'
    # refactor what about other org types and associated charity/company numbers
    job_role User::JOB_ROLES.first
    user_email 'john@organisation.org'
    password 'password123'
    role 'User'
    agree_to_terms true
  end
end
