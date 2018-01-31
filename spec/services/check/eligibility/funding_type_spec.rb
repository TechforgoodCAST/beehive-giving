require 'rails_helper'

describe Check::Eligibility::FundingType do
  let(:assessment) do
    build(:assessment, proposal: build(:proposal, funding_type: funding_type))
  end
  let(:eligibility) { assessment.eligibility_funding_type }

  before { subject.call(assessment) }

  context 'permitted funding_type' do
    let(:funding_type) { 1 }
    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
  end

  context 'unpermitted funding_type' do
    let(:funding_type) { 3 }
    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }
  end

  context 'unknown funding_type' do
    let(:funding_type) { 0 }
    it('ineligible') { expect(eligibility).to eq(ELIGIBLE) }
  end
end
