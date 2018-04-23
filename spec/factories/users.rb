FactoryBot.define do
  factory :user do
    agree_to_terms true
    sequence(:email) { |n| "email#{n}@organisation.org" }
    first_name 'John'
    last_name 'Doe'
    marketing_consent true
    password 'password123'

    factory :registered_user, class: User do
      after(:build) do |user, _evaluator|
        proposal = build(:proposal)
        alpha2 = proposal.countries.last.alpha2
        recipient = build(:recipient, country: alpha2, proposals: [proposal])
        user.organisation = recipient
      end
    end
  end
end
