FactoryGirl.define do
  factory :eligibility do
    association :recipient, :factory => :recipient
    association :restriction, :factory => :restriction
    eligible true
  end

  factory :restriction do
    transient do
      n { rand(9999) }
    end
    details { "Random restriction #{n}" }
  end

  factory :funding_stream do
    funders {FactoryGirl.create_list(:funder, 1)}
    restrictions {FactoryGirl.create_list(:restriction, 1)}
    label "Funding stream name"
  end
end
