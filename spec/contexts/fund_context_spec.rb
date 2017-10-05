describe FundContext do
  subject do
    FundContext.new(fund, proposal)
  end

  let(:fund) { Fund.new(slug: 'fund') }
  let(:proposal) { Proposal.new() }

  it 'self.policy_class' do
    expect(FundContext.policy_class).to eq FundPolicy
  end

  it '#slug' do
    expect(subject.slug).to eq 'fund'
  end
end
