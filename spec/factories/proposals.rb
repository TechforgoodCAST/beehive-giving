FactoryGirl.define do
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
    gender                Proposal::GENDERS[1]
    beneficiaries_other_required false
    affect_geo            Proposal::AFFECT_GEO.sample[1]
    private               false
    after(:create, &:initial_recommendation)

    factory :registered_proposal do
      state            'registered'
      sequence(:title) { |n| "Title#{n}" }
      tagline          'Tagline'
      outcome1         'Outcome 1'

      factory :proposal do
        state 'complete'
      end
    end
  end
end
