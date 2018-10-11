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

    transient do
      children true
    end

    after(:build) do |proposal, opts|
      if opts.children
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

    factory :proposal_no_funding, class: Proposal do
      category_code 101 # Other
      max_amount nil
      max_duration nil
      min_amount nil
      min_duration nil
    end
  end
end
