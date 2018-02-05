FactoryBot.define do
  factory :implementation do
    sequence(:label, (0..7).cycle) do |i|
      Implementation::IMPLEMENTATIONS[i][:label]
    end
  end
end
