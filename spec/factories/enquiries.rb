FactoryBot.define do
  factory :enquiry do
    association :fund, strategy: :build
    association :proposal, strategy: :build
  end
end
