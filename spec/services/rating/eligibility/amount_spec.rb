require 'rails_helper'
require 'services/rating/shared'

describe Rating::Eligibility::Amount do
  subject { Rating::Eligibility::Amount.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#title') { expect(subject.title).to eq('Amount') }

  it_behaves_like 'incomplete'

  context 'ineligible' do
    let(:assessment) { build(:assessment, eligibility_amount: 0) }

    it_behaves_like 'ineligible'

    it '#message' do
      msg = 'You are ineligible due to the <strong>amount</strong> your are ' \
            'seeking.'
      expect(subject.message).to eq(msg)
    end
  end

  context 'eligible' do
    let(:assessment) { build(:assessment, eligibility_amount: 1) }

    it_behaves_like 'eligible'

    it '#message' do
      msg = 'Awards grants <strong>between £5,000 and £10,000</strong>.'
      expect(subject.message).to eq(msg)
    end
  end
end
