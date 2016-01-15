FactoryGirl.define do
  factory :recipient, class: Recipient do
    transient do
      n  { rand(9999) }
    end
    org_type 3
    name "ACME"
    website "http://www.acme.com"
    country "GB"
    status Organisation::STATUS.first
    registered true
    charity_number { "1AB1C#{n}" }
    company_number { "1AB1C#{n}" }
    founded_on "01/01/2014"
    registered_on "01/01/2015"
  end

  factory :recipient_attribute, class: RecipientAttribute do
    association :recipient, :factory => :recipient
    problem "Problem"
    solution "Solution"
  end
end
