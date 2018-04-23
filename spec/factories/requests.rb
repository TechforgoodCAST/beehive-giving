FactoryBot.define do
  factory :request do
    association :recipient, strategy: :build
    association :fund, strategy: :build
  end
end
