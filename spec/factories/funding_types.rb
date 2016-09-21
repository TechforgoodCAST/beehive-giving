FactoryGirl.define do
  factory :funding_type do
    sequence(:label, (0..FundingType::FUNDING_TYPE.length).cycle) do |i|
      FundingType::FUNDING_TYPE[i]
    end
  end
end
