FactoryGirl.define do

  factory :recommendation do
    association :recipient, :factory => :recipient
    association :funder, :factory => :funder
    score 0
  end

end
