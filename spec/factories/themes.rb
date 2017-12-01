FactoryGirl.define do
  factory :theme do
    sequence(:name) { |n| "Theme#{n}" }
    sequence(:slug) { |n| "theme#{n}" }
    classes 'tag-red white'
  end
end
