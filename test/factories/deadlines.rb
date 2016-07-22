FactoryGirl.define do
  factory :deadline do
    fund
    deadline { 1.month.until }
  end
end
