FactoryBot.define do
  factory :user do
    transient do
      n { rand(9999) }
    end
    email { "email#{n}@organisation.org" }
    email_confirmation { "email#{n}@organisation.org" }
    first_name 'John'
    last_name 'Doe'
    marketing_consent true
    terms_agreed true
  end
end
