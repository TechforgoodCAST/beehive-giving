require 'rails_helper'
require 'services/rating/shared'

describe Rating::Eligibility::FundingType do
  subject { Rating::Eligibility::FundingType.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#title') { expect(subject.title).to eq('Type of funding') }

  it_behaves_like 'incomplete'

  context 'ineligible' do
    let(:assessment) { build(:assessment, eligibility_funding_type: INELIGIBLE) }

    it_behaves_like 'ineligible'

    it '#message' do
      msg = 'Does not award <strong>capital</strong> grants.'
      expect(subject.message).to eq(msg)
    end
  end

  context 'eligible' do
    let(:assessment) { build(:assessment, eligibility_funding_type: ELIGIBLE) }

    it_behaves_like 'eligible'

    it '#message' do
      msg = 'Awards <strong>capital & revenue</strong> grants.'
      expect(subject.message).to eq(msg)
    end
  end
end
