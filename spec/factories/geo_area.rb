FactoryGirl.define do
  factory :geo_area do
    sequence(:name) { |n| "Area #{n}" }
  end
end
