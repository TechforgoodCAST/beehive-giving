FactoryBot.define do
  factory :individual, class: Recipient do
    category_code 101 # An individual

    after(:build) do |recipient, _evaluator|
      country = build(:country)
      recipient.country = country
      recipient.district = build(:district, country: country)
      recipient.answers = Array.new(2) do
        build(:recipient_answer, eligible: true)
      end
    end

    factory :recipient do
      category_code  301 # A charitable organisation
      charity_number '098765'
      company_number '012345'
      description    'Charity registered in England & Wales'
      income_band    INCOME_BANDS[1][1] # 10k - 100k
      name           'Charity projects'
      operating_for  OPERATING_FOR[1][1] # Less than 12 months
      website        'http://example.com'
    end
  end
end
