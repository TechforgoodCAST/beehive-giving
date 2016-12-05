FactoryGirl.define do
  factory :country do
    sequence(:name, (0..1).cycle) { |i| ['United Kingdom', 'Kenya'][i] }
    sequence(:alpha2, (0..1).cycle) { |i| %w(GB KE)[i] }
  end
end
