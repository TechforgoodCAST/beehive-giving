FactoryGirl.define do
  factory :organisation, class: Recipient do
    transient do
      n 1
    end
    name { "Random #{n}" }
    website { "www.random#{n}.com" }
    country "GB"
    status Organisation::STATUS.first
    registered true
    charity_number { "1AB1C#{n}" }
    company_number { "1AB1C#{n}" }
    founded_on "01/01/2014"
    registered_on "01/01/2015"
  end

  factory :blank_org, class: Recipient do
  end
end
