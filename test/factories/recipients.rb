FactoryGirl.define do

  factory :recipient do
    transient do
      n { rand(9999) }
    end
    org_type 3
    charity_number  { "1AB1C#{n}" }
    company_number  { "1AB1C#{n}" }
    name            "ACME"
    country         "GB"
    operating_for   Organisation::OPERATING_FOR[1][1]
    income          Organisation::INCOME[1][1]
    employees       Organisation::EMPLOYEES.sample[1]
    volunteers      Organisation::EMPLOYEES.sample[1]
    website         "http://www.acme.com"
  end

  factory :blank_org, class: Recipient do; end

end
