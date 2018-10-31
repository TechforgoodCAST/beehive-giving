FactoryBot.define do
  factory :criterion, aliases: [:restriction] do
    sequence(:details) { |n| "Criterion #{n}" }

    factory :priority, class: Priority
  end
end
