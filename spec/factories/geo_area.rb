FactoryBot.define do
  factory :geo_area do
    sequence(:name) { |n| "Area #{n}" }

    after(:build) do |area, _evaluator|
      country = build(:country)
      area.countries = [country]
      area.districts = build_list(:district, 1, country: country)
    end
  end
end
