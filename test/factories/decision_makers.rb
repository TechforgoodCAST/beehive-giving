FactoryGirl.define do
  factory :decision_maker do
    sequence(:name) { |n| "Name#{n}" }
  end
end
