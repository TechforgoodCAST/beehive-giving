FactoryGirl.define do
  factory :feedback do
    association :user, :factory => :user
    nps 10
    taken_away 10
    informs_decision 10
  end
end
