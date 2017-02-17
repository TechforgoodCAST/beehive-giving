FactoryGirl.define do
  factory :restriction do
    sequence(:details) { |n| "Random restriction #{n}" }

    factory :recipient_restriction, class: 'Restriction' do
      category 'Organisation'
    end
  end
end
