FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    job_role 'CEO'
    user_email 'john@organisation.org'
    password 'password123'
    password_confirmation 'password123'
    role 'User'
  end

  # factory :user, class: User do
  #   transient do
  #     n 1
  #   end
  #   first_name { 'First #{n}' }
  #   last_name { 'Last #{n}' }
  #   job_role 'CEO'
  #   user_email { 'user#{n}@organisation#{n}.org' }
  #   password 'password123'
  #   password_confirmation 'password123'
  #   role 'User'
  # end
  #
  # factory :blank_user, class: User do
  # end
end
