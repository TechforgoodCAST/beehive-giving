FactoryGirl.define do

  factory :initial_proposal, class: Proposal do
    association :recipient, factory: :recipient

    type_of_support Proposal::TYPE_OF_SUPPORT.sample
    funding_duration 12
    funding_type Proposal::FUNDING_TYPE.sample
    total_costs 1000
    total_costs_estimated false
    all_funding_required true

    affect_people true
    affect_other false
    gender Proposal::GENDERS.sample
    age_groups { FactoryGirl.create_list(:age_group, 8) }
    beneficiaries { FactoryGirl.create_list(:beneficiary, 2) }
    beneficiaries_other_required false

    affect_geo Proposal::AFFECT_GEO.sample[1]
    countries { FactoryGirl.create_list(:country, 1) }
    districts { FactoryGirl.create_list(:district, 2, country: Country.first) }

    after(:build) do |object|
      object.build_proposal_recommendation
    end
  end

end
