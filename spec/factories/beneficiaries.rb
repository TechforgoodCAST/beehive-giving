FactoryBot.define do
  factory :beneficiary do
    sequence(:label, (0..24).cycle) do |i|
      Beneficiary::BENEFICIARIES[i][:label]
    end
    sequence(:category, (0..24).cycle) do |i|
      Beneficiary::BENEFICIARIES[i][:category]
    end
    sequence(:sort, (0..24).cycle) do |i|
      Beneficiary::BENEFICIARIES[i][:sort]
    end
  end
end
