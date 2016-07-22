FactoryGirl.define do
  factory :restriction do
    sequence(:details) { |n| "Random restriction #{n}" }
  end
end
