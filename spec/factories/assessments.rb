FactoryBot.define do
  factory :assessment, aliases: [:incomplete] do
    association :fund, strategy: :build
    association :proposal, strategy: :build
    association :recipient, strategy: :build

    after(:build) do |assessment, _evaluator|
      assessment.valid?
    end

    factory :eligible do
      eligibility_amount       ELIGIBLE
      eligibility_funding_type ELIGIBLE
      eligibility_location     ELIGIBLE
      eligibility_org_income   ELIGIBLE
      eligibility_org_type     ELIGIBLE
      eligibility_quiz         ELIGIBLE
      factory :ineligible do
        eligibility_location INELIGIBLE
      end
    end
  end
end
