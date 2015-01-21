FactoryGirl.define do
  factory :grant do
    funding_stream "Main"
    grant_type "Unrestricted"
    attention_how "Headhunting"
    amount_awarded 10000
    amount_applied 10000
    installments 1
    approved_on Date.new(2015, 1, 1)
    start_on Date.new(2015, 1, 1)
    end_on Date.new(2015, 1, 1)
    attention_on Date.new(2015, 1, 1)
    applied_on Date.new(2015, 1, 1)
  end
end
