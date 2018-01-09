FactoryBot.define do
  factory :age_group do
    sequence(:label, (0..7).cycle) do |i|
      AgeGroup::AGE_GROUPS[i][:label]
    end
    sequence(:age_from, (0..7).cycle) do |i|
      AgeGroup::AGE_GROUPS[i][:age_from]
    end
    sequence(:age_to, (0..7).cycle) do |i|
      AgeGroup::AGE_GROUPS[i][:age_to]
    end
  end
end
