FactoryGirl.define do
  factory :organisation, class: Recipient do
    transient do
      n { rand(9999) }
    end
    org_type 3
    name { "Random #{n}" }
    website { "http://www.random#{n}.com" }
    country "GB"
    status Organisation::STATUS.first
    registered true
    charity_number { "1AB1C#{n}" }
    company_number { "1AB1C#{n}" }
    operating_for Organisation::OPERATING_FOR.sample[1]
    multi_national false
  end

  factory :blank_org, class: Recipient do
  end
end
