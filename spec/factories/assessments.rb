FactoryBot.define do
  factory :assessment do
    association :fund, strategy: :build
    association :proposal, strategy: :build
    association :recipient, strategy: :build
  end
end
