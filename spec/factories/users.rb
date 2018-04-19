FactoryBot.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    sequence(:email) { |n| "email#{n}@organisation.org" }
    password 'password123'
    agree_to_terms true

    factory :registered_user, class: User do
      after(:build) do |user, _evaluator|
        user.organisation = build(:recipient, proposals: [build(:proposal)])
      end
    end
  end
end
