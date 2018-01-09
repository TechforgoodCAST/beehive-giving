FactoryBot.define do
  factory :funder do
    transient do
      n { rand(9999) }
    end
    name 'Funder'
    website 'http://www.funder.org'
    active true
  end
end
