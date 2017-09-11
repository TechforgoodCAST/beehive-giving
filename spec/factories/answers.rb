FactoryGirl.define do
  factory :answer do
    restriction
    eligible true

    factory :proposal_eligibility, class: Answer do
      category { |e| e.association(:proposal) }
    end

    factory :recipient_eligibility, class: Answer do
      category { |e| e.association(:recipient) }
    end
  end
end
