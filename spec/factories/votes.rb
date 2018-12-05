FactoryBot.define do
  factory :vote do
    assessment

    relationship_to_assessment 'Another role'
    relationship_details 'Expert'
    agree_with_rating false
    reason 'Some reason...'

    factory :vote_agree, class: Vote do
      relationship_to_assessment 'I created the report'
      agree_with_rating true
    end
  end
end
