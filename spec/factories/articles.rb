FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article Title #{n}" }
    sequence(:slug) { |n| "article-title-#{n}" }
    body '## <strong>www.beehivegiving.org</strong>'
  end
end
