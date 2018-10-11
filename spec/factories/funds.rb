FactoryBot.define do
  factory :fund do
    funder

    sequence(:name) { |n| "Awards for All #{n}" }
    description 'Some description of the fund.'
    website 'http://opportunity.link'

    links { { 'Recent grants' => 'http://grantnav.link' } }

    after(:build) do |fund, _evaluator|
      fund.themes = build_list(:theme, 1) unless fund.themes.any?
    end

    factory :fund_with_rules, class: Fund do
      # Check::Eligibility::Amount
      proposal_min_amount 300
      proposal_max_amount 10_000

      # Check::Eligibility::Duration
      proposal_min_duration 9
      proposal_max_duration 12

      # Check::Eligibility::Income
      recipient_min_income 50_000
      recipient_max_income nil

      # Check::Eligibility::Location
      proposal_permitted_geographic_scales %w[local regional]
      proposal_area_limited true
      proposal_all_in_area true
      association :geo_area, strategy: :build

      # Check::Eligibility::ProposalCategories
      proposal_categories [202, 203] # Revenue - Core, Revenue - Project

      # Check::Eligibility::RecipientCategories
      recipient_categories [203, 301] # An unregistered charity, A charitable organisation

      # Check::Eligibility::Quiz
      after(:build) do |fund, _evaluator|
        fund.restrictions << build_list(:restriction, 2, category: 'Recipient')
        fund.restrictions << build_list(:restriction, 2)
      end

      # Check::Suitability::Quiz
      after(:build) do |fund, _evaluator|
        fund.priorities = build_list(:priority, 2)
      end
    end
  end
end
