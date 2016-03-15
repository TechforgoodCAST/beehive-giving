FactoryGirl.define do
  factory :recipient, class: Recipient do
    transient do
      n { rand(9999) }
    end
    org_type 3
    name "ACME"
    website "http://www.acme.com"
    country "GB"
    status Organisation::STATUS.first
    registered true
    charity_number { "1AB1C#{n}" }
    company_number { "1AB1C#{n}" }
    operating_for Organisation::OPERATING_FOR.sample[1]
    multi_national false
  end

  factory :recipient_attribute, class: RecipientAttribute do
    association :recipient, :factory => :recipient
    problem "Problem"
    solution "Solution"
  end
end
