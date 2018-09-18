FactoryBot.define do
  factory :country do
    sequence(:name) { |n| "Country #{n}" }
    sequence(:alpha2) { |n| "GB#{n}" }
  end
end
