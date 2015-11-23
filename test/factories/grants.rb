FactoryGirl.define do
  factory :grant do
    association :funder, :factory => :funder
    association :recipient, :factory => :recipient
    funding_stream "All"
    grant_type "Unrestricted"
    attention_how "Headhunting"
    amount_awarded 10000
    amount_applied 10000
    installments 1
    approved_on Date.new(Date.today.year, 1, 2)
    start_on Date.new(Date.today.year, 1, 2)
    end_on Date.new(Date.today.year, 1, 2)
    attention_on Date.new(Date.today.year, 1, 2)
    applied_on Date.new(Date.today.year, 1, 2)
    open_call true
    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
    after(:build) do |object|
      object.default_values
    end
  end

  factory :grants, class: Grant do
    transient do
      n { rand(0..9) }
      s { rand(0..1) }
      c { rand(0..3) }
    end
    association :funder, :factory => :funder
    association :recipient, :factory => :recipient
    funding_stream { ["All", "Main"][s] }
    grant_type "Unrestricted"
    attention_how "Headhunting"
    amount_awarded { "1000#{n}" }
    amount_applied { "1000#{n}" }
    installments 1
    approved_on Date.new(Date.today.year, 1, 2)
    start_on Date.new(Date.today.year, 1, 2)
    end_on Date.new(Date.today.year, 1, 2)
    attention_on Date.new(Date.today.year, 1, 2)
    applied_on Date.new(Date.today.year, 1, 2)
    open_call [true, false].sample
    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
    after(:build) do |object|
      object.default_values
    end
  end

  factory :grants_first_jan, class: Grant do
    transient do
      n { rand(0..9) }
      s { rand(0..1) }
      c { rand(0..3) }
    end
    association :funder, :factory => :funder
    association :recipient, :factory => :recipient
    funding_stream { ["All", "Main"][s] }
    grant_type "Unrestricted"
    attention_how "Headhunting"
    amount_awarded { "1000#{n}" }
    amount_applied { "1000#{n}" }
    installments 1
    approved_on Date.new(Date.today.year, 1, 1)
    start_on Date.new(Date.today.year, 1, 1)
    end_on Date.new(Date.today.year, 1, 1)
    attention_on Date.new(Date.today.year, 1, 1)
    applied_on Date.new(Date.today.year, 1, 1)
    open_call [true, false].sample
    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
    after(:build) do |object|
      object.default_values
    end
  end

end
