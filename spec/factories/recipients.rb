FactoryBot.define do
  factory :individual, class: Recipient do
    category_code 101 # An individual

    after(:build) do |recipient, _evaluator|
      unless recipient.country
        country = build(:country)
        recipient.country = country
      end
      recipient.district = build(:district, country: country)
    end

    factory :recipient do
      category_code  301 # A charitable organisation
      charity_number '098765'
      company_number '012345'
      description    'Charity registered in England & Wales'
      income_band    Recipient::INCOME_BANDS[1][:label] # 10k - 100k
      name           'Charity projects'
      operating_for  Recipient::OPERATING_FOR[1] # Less than 12 months
      website        'http://example.com'
    end
  end
end
