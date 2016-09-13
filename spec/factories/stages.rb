FactoryGirl.define do
  factory :stage do
    fund
    sequence(:name, (0..Stage::STAGES.length-1).cycle) do |i|
      Stage::STAGES[i]
    end
    sequence(:position)
    feedback_provided false
  end
end
