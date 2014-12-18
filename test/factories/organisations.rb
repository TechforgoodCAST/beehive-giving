FactoryGirl.define do
  factory :acme, class: Organisation do
    name "ACME"
    contact_name "John Doe"
    contact_role "CEO"
    contact_email "hello@hello.com"
  end

  factory :organisation, class: Organisation do
    transient do
      n 1
    end
    name { "Random #{n}" }
    contact_name { "Mr Random #{n}" }
    contact_role "CEO"
    contact_email { "#{n}@random.com" }
  end

  factory :blank_org, class: Organisation do
  end
end
