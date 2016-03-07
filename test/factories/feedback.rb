FactoryGirl.define do
  factory :feedback do
    association :user, :factory => :user
    suitable 10
    most_useful Feedback::MOST_USEFUL.sample
    nps 10
    taken_away 10
    informs_decision 10
    application_frequency Feedback::APP_AND_GRANT_FREQUENCY.sample
    grant_frequency Feedback::APP_AND_GRANT_FREQUENCY.sample
    marketing_frequency Feedback::MARKETING_FREQUENCY.sample
  end
end
