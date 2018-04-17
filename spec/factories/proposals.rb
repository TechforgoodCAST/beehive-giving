FactoryBot.define do
  factory :proposal do
    affect_geo  1 # One or more regions
    all_funding_required true
    funding_duration 12
    funding_type 1 # Capital
    private false
    recipient
    tagline 'Description'
    title 'Title'
    total_costs 10_000

    after(:build) do |proposal, _evaluator|
      proposal.themes = build_list(:theme, 1) unless proposal.themes.any?

      unless proposal.countries.any? || proposal.districts.any?
        country = build(:country)
        proposal.countries = [country]
        proposal.districts = [build(:district, country: country)]
      end
    end
  end
end
