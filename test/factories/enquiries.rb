FactoryGirl.define do

  factory :enquiry do
    association :recipient, :factory => :recipient
    association :funder, :factory => :funder
    new_project false
    new_location false
    amount_seeking 50000
    duration_seeking 12
    approach_funder_count 1
    # suggestion_quality "Good suggestion" #remove?
  end

  factory :enquiry_new_location_and_project, class: Enquiry do
    association :recipient, :factory => :recipient
    association :funder, :factory => :funder
    new_project true
    new_location true
    amount_seeking 50000
    duration_seeking 12
    approach_funder_count 1
    suggestion_quality "Good suggestion"
    countries {FactoryGirl.create_list(:country, 2)}
    districts {FactoryGirl.create_list(:district, 2)}
  end

end
