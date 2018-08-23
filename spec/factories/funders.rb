FactoryBot.define do
  factory :funder do
    name 'Funder'
    website 'http://www.funder.org'
    active true

    factory :funder_with_funds, class: Funder do
      after(:create) do |funder, _evaluator|
        funder.funds = create_list(:fund_simple, 2)
      end
    end
  end
end
