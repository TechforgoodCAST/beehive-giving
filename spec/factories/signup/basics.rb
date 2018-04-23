FactoryBot.define do
  factory :signup_basics, class: Signup::Basics do
    country 'GB'
    funding_type FUNDING_TYPES[1][1] # Capital
    org_type 0 # An unregistered organisation OR project
    themes ['', '1']
  end
end
