FactoryBot.define do
  factory :proposal do
    association :collection, factory: :funder, strategy: :build
    association :recipient, factory: :recipient, strategy: :build
    association :user, factory: :user, strategy: :build
    category_code 202 # Revenue - Core
    description 'A new roof for our community centre.'
    geographic_scale 'local'
    max_amount 250_000
    max_duration 36
    min_amount 10_000
    min_duration 3
    public_consent true
    title 'Community space'

    after(:build) do |proposal, _evaluator|
      proposal.themes = build_list(:theme, 1)
      country = build(:country)
      proposal.countries = [country]
      proposal.districts = build_list(:district, 1, country: country)
      restriction = build(:restriction, category: 'Proposal')
      priority = build(:priority, category: 'Proposal')
      proposal.answers = [
        build(:answer, category: proposal, criterion: restriction),
        build(:answer, category: proposal, criterion: priority)
      ]
    end
  end
end
