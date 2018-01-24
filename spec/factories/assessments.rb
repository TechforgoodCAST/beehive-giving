FactoryBot.define do
  factory :assessment do
    association :fund, strategy: :build
    association :proposal, strategy: :build
    association :recipient, strategy: :build

    after(:build) do |assessment, _evaluator|
      assessment.valid?
    end

    factory :eligible do
      eligibility_amount 1
      eligibility_location 1
      eligibility_org_income 1
      eligibility_org_type 1
      eligibility_quiz 1
      factory :ineligible do
        eligibility_location 0
      end
    end
  end
end
