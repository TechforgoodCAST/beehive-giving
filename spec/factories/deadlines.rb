FactoryGirl.define do
  factory :deadline do
    fund
    deadline { 1.month.since }
  end
end
