FactoryBot.define do
  factory :theme do
    sequence(:name) { |n| "Theme#{n}" }
    classes 'tag-red white'
  end
end
