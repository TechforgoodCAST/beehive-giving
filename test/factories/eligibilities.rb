FactoryGirl.define do
  factory :restriction do
    funders {FactoryGirl.create_list(:funder, 2)}
    details "Restriction details"
  end

  factory :eligibility do
    association :recipient, :factory => :recipient
    association :restriction, :factory => :restriction
    eligible true
  end
end
