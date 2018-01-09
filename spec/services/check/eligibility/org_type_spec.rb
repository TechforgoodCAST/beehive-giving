require 'rails_helper'

describe Check::Eligibility::OrgType do
  let(:assessment) do
    build(:assessment, recipient: build(:recipient, org_type: org_type))
  end
  let(:eligibility) { assessment.eligibility_org_type }

  before { subject.call(assessment) }

  context 'permitted org_type' do
    let(:org_type) { 1 }
    it('eligible') { expect(eligibility).to eq(1) }
  end

  context 'unpermitted org_type' do
    let(:org_type) { 0 }
    it('ineligible') { expect(eligibility).to eq(0) }
  end
end
