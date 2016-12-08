FactoryGirl.define do
  factory :funder do
    transient do
      n { rand(9999) }
    end
    org_type 3
    charity_number { "1AB1C#{n}" }
    company_number { "1AB1C#{n}" }
    name 'ACME'
    country 'GB'
    operating_for Organisation::OPERATING_FOR.sample[1]
    income Organisation::INCOME.sample[1]
    employees Organisation::EMPLOYEES.sample[1]
    volunteers Organisation::EMPLOYEES.sample[1]
    website 'http://www.acme.com'
    active_on_beehive true
  end
end
