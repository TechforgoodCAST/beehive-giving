FactoryBot.define do
  factory :proposal do
    recipient
    funding_duration      12
    funding_type          1 # Capital
    total_costs           10_000
    all_funding_required  true
    affect_geo            1 # One or more regions
    private               false

    after(:build) do |proposal, _evaluator|
      proposal.themes = build_list(:theme, 1) unless proposal.themes.any?

      unless proposal.countries.any? || proposal.districts.any?
        country = build(:country)
        proposal.countries = [country]
        proposal.districts = [build(:district, country: country)]
      end
    end

    factory :registered_proposal do
      state            'registered'
      sequence(:title) { |n| "Title#{n}" }
      tagline          'Tagline'
      outcome1         'Outcome 1'

      # TODO: deprecated
      after(:build) do |proposal, _evaluator|
        proposal.implementations = create_list(:implementation, 1)
      end

      factory :complete_proposal do
        state 'complete'
      end
    end
  end
end
