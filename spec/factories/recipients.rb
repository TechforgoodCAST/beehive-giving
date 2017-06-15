FactoryGirl.define do
  factory :legacy_recipient, class: Recipient do
    transient do
      n { rand(9999) }
    end
    org_type        ORG_TYPES[4][1] # Another type of organisation
    charity_number  { "1AB1C#{n}" }
    company_number  { "1AB1C#{n}" }
    name            'ACME'
    country         'GB'
    operating_for   Organisation::OPERATING_FOR[1][1] # Less than 12 months
    website         'http://www.acme.com'

    factory :recipient do
      income        Organisation::INCOME[1][1] # 10k - 100k
      employees     Organisation::EMPLOYEES[1][1] # 1 - 5
      volunteers    Organisation::EMPLOYEES[1][1] # 1 - 5
    end
  end
end
