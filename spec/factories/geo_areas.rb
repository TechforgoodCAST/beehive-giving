FactoryBot.define do
  factory :geo_area do
    sequence(:name) { |n| "Area #{n}" }

    transient do
      children { true }
    end

    after(:build) do |area, opts|
      if opts.children
        country = build(:country)
        area.countries = [country]
        area.districts = build_list(:district, 1, country: country)
      end
    end
  end
end
