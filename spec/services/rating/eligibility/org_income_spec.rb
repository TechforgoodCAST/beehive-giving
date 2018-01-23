require 'rails_helper'
require 'services/rating/shared'

describe Rating::Eligibility::OrgIncome do
  subject { Rating::Eligibility::OrgIncome.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#title') { expect(subject.title).to eq('Income') }

  it_behaves_like 'incomplete'

  context 'ineligible' do
    let(:assessment) { build(:assessment, eligibility_org_income: 0) }

    it_behaves_like 'ineligible'

    it '#message' do
      msg = 'You are ineligible due to your <strong>income</strong>.'
      expect(subject.message).to eq(msg)
    end
  end

  context 'eligible' do
    let(:assessment) { build(:assessment, eligibility_org_income: 1) }

    it_behaves_like 'eligible'

    it '#message' do
      msg = 'Awards funds to organisations with ' \
            '<strong>between £10,000 and £250,000</strong> income.'
      expect(subject.message).to eq(msg)
    end
  end
end
