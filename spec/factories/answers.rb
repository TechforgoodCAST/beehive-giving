FactoryGirl.define do
  factory :answer do
    eligible true

    factory :proposal_eligibility, class: Answer do
      category { |e| e.association(:proposal) }
      question { |e| e.association(:question) }
    end

    factory :recipient_eligibility, class: Answer do
      category { |e| e.association(:recipient) }
      question { |e| e.association(:question) }
    end

    factory :proposal_suitability, class: Answer do
      category { |e| e.association(:proposal) }
      question { |e| e.association(:question) }
    end

    factory :recipient_suitability, class: Answer do
      category { |e| e.association(:recipient) }
      question { |e| e.association(:question) }
    end
  end
end
