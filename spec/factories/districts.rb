FactoryBot.define do
  factory :district do
    country
    sequence(:name) { |n| "District #{n}" }
  end
end
