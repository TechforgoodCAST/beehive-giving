FactoryGirl.define do
  factory :theme do
    sequence(:name) { |n| "Theme#{n}" }
    sequence(:slug) { |n| "theme#{n}" }
  end
end
