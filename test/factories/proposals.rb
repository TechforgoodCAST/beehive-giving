FactoryGirl.define do

  factory :beneficiary do
    label     'People'
    category  'People'
  end

  factory :age_group do
    sequence(:label, (0..7).cycle) { |n| ['All ages', 'Infants (0-3 years)', 'Children (4-11 years)', 'Adolescents (12-19 years)', 'Young adults (20-35 years)', 'Adults (36-50 years)', 'Mature adults (51-80 years)', 'Older adults (80+)'][n] }
    sequence(:age_from, (0..7).cycle) { |n| [0, 0, 4, 12, 20, 36, 51, 80][n] }
    sequence(:age_to, (0..7).cycle) { |n| [150, 3, 11, 19, 35, 50, 80, 150][n] }
  end

  factory :implementation do
    label 'Some activity'
  end

  factory :initial_proposal, class: Proposal do
    recipient
    type_of_support       Proposal::TYPE_OF_SUPPORT.sample
    funding_duration      12
    funding_type          Proposal::FUNDING_TYPE.sample
    total_costs           10000
    total_costs_estimated false
    all_funding_required  true
    affect_people         true
    affect_other          false
    gender                Proposal::GENDERS.sample
    age_groups            { FactoryGirl.create_list(:age_group, 8) }
    beneficiaries         { FactoryGirl.create_list(:beneficiary, 2) }
    beneficiaries_other_required false
    affect_geo            Proposal::AFFECT_GEO.sample[1]
    # countries             { FactoryGirl.create_list(:country, 1) }
    # districts             { FactoryGirl.create_list(:district, 2, country: Country.first) }
    private               false
    after(:create)        { |proposal| proposal.initial_recommendation }

    factory :registered_proposal do
      state            'registered'
      sequence(:title) { |n| "Title#{n}" }
      tagline          'Tagline'
      implementations  { FactoryGirl.create_list(:implementation, 1) }
      outcome1         'Outcome 1'

      factory :proposal do
        state 'complete'
      end
    end
  end

end
