FactoryBot.define do
  factory :answer do
    eligible true

    factory :proposal_eligibility, class: Answer do
      category { |e| e.association(:proposal) }
      criterion { |e| e.association(:criterion) }
    end

    factory :recipient_eligibility, class: Answer do
      category { |e| e.association(:recipient) }
      criterion { |e| e.association(:criterion) }
    end

    factory :proposal_suitability, class: Answer do
      category { |e| e.association(:proposal) }
      criterion { |e| e.association(:criterion) }
    end

    factory :recipient_suitability, class: Answer do
      category { |e| e.association(:recipient) }
      criterion { |e| e.association(:criterion) }
    end
  end
end
