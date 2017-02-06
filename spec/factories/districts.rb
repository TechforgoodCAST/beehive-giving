FactoryGirl.define do
  factory :district do
    country
    sequence(:name, (0..2).cycle) { |i| %w(Arun Ashfield Ashford)[i] }
    sequence(:subdivision, (0..2).cycle) { |i| %w(45UC 37UB 29UB)[i] }
    sequence(:region, (0..2).cycle) { |i| ['South East', 'East Midlands', 'South East'][i] }
    sequence(:sub_country, (0..2).cycle) { |i| %w(England England England)[i] }
  end

  factory :kenya_district, class: District do
    country
    sequence(:name, (0..2).cycle) { |i| %w(Mombasa Kwale Kilifi)[i] }
    sequence(:subdivision, (0..2).cycle) { |i| %w(1 2 3)[i] }
  end

  factory :blank_district, class: District do
    country
  end
end
