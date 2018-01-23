require 'rails_helper'
require 'services/rating/shared'

describe Rating::Eligibility::OrgType do
  subject { Rating::Eligibility::OrgType.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#title') { expect(subject.title).to eq('Recipient') }

  it_behaves_like 'incomplete'

  context 'ineligible' do
    let(:assessment) { build(:assessment, eligibility_org_type: 0) }

    it_behaves_like 'ineligible'

    it '#message' do
      msg = 'Does not award funds to <strong>registered companies</strong>.'
      expect(subject.message).to eq(msg)
    end
  end

  context 'eligible' do
    let(:assessment) { build(:assessment, eligibility_org_type: 1) }

    it_behaves_like 'eligible'

    it '#message' do
      msg = 'Awards funds to <strong>registered companies</strong>.'
      expect(subject.message).to eq(msg)
    end
  end
end
