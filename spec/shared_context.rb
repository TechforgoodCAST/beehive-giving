RSpec.shared_context 'shared context', shared_context: :metadata do
  let(:proposal) do
    build(
      :proposal,
      id: 1,
      eligibility: { 'fund' => eligibility },
      suitability: { 'fund' => suitability }
    )
  end
  let(:fund) { build(:fund, id: 1, slug: 'fund') }
  let(:eligibility) { {} }
  let(:suitability) { {} }
end

RSpec.configure do |rspec|
  rspec.include_context 'shared context', include_shared: true
end
