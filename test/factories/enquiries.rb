FactoryGirl.define do

  factory :enquiry do
    association :recipient, :factory => :recipient
    association :funder, :factory => :funder
    funding_stream "All"
  end

end
