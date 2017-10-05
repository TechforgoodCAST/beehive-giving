describe EligibilityContext do
  subject do
    EligibilityContext.new(fund, proposal)
  end

  let(:fund) { Fund.new(slug: 'fund') }
  let(:proposal) { Proposal.new(eligibility: eligibility) }
  let(:eligibility) { { fund.slug => { 'quiz' => 1 }} }

  it '#checked_fund? true' do
    expect(subject.checked_fund?).to eq true
  end

  context 'unchecked' do
    let(:eligibility) { {} }

    it '#checked_fund? false' do
      expect(subject.checked_fund?).to eq false
    end
  end
end
