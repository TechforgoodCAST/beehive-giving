FactoryGirl.define do
  factory :eligibility do
    restriction
    eligible true

    factory :proposal_eligibility, class: Eligibility do
      category { |e| e.association(:proposal) }
    end

    factory :recipient_eligibility, class: Eligibility do
      category { |e| e.association(:recipient) }
    end
  end
end
