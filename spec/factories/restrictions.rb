FactoryBot.define do
  factory :restriction do
    sequence(:details, %w[Undesired Desired].cycle) do |n|
      "#{n} restriction #{rand(9999)}"
    end
    sequence(:invert, [false, true].cycle) { |i| i }

    # TODO: refactor
    factory :recipient_restriction, class: 'Restriction' do
      category 'Recipient'
    end
  end
end
