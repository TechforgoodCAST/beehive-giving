FactoryBot.define do
  # TODO: refactor aliases
  factory :answer, aliases: [:proposal_eligibility, :proposal_suitability] do
    eligible true
    association :category, factory: :proposal
    association :criterion, factory: :restriction

    factory :recipient_eligibility, class: Answer do
      association :category, factory: :recipient
    end
  end
end
