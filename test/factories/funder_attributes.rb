FactoryGirl.define do
  factory :funder_attribute, :class => 'FunderAttributes' do
    application_process 1
next_deadline "2015-03-05"
funding_round_frequency 1
funding_streams 1
funding_type 1
  end

end
