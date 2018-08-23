# TODO: refactor
FactoryBot.define do
  factory :answer, aliases: [:proposal_eligibility, :proposal_suitability] do
    eligible true
    association :category, factory: :proposal
    association :criterion, factory: :restriction

    factory :recipient_eligibility, class: Answer do
      association :category, factory: :recipient
    end
  end

  factory :recipient_answer, class: Answer do
    association :criterion, factory: :restriction, strategy: :build
  end
end
