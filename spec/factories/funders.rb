FactoryBot.define do
  factory :funder do
    sequence(:name) { |n| "Funder #{n}" }
    website { 'http://www.funder.org' }
    active { true }

    factory :funder_with_funds, class: Funder do
      after(:create) do |funder, _evaluator|
        funder.funds = create_list(:fund_with_rules, 2)
      end
    end
  end
end
