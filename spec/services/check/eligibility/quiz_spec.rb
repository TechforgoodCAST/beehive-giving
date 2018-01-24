require 'rails_helper'

describe Check::Eligibility::Quiz do
  let(:assessment) do
    build(
      :assessment,
      fund: build(
        :fund,
        themes: build_list(:theme, 1),
        restrictions: restrictions,
        priorities_known: false
      ),
      recipient: create(
        :recipient,
        answers: [build(
          :recipient_eligibility,
          criterion: restrictions.first,
          eligible: eligible
        )]
      )
    )
  end
  let(:restrictions) { build_list(:restriction, num, category: 'Recipient') }
  let(:num) { 1 }
  let(:eligible) { true }
  let(:eligibility) { assessment.eligibility_quiz }
  let(:incomplete) { assessment.eligibility_quiz_failing }

  before { subject.call(assessment) }

  context 'with incomplete answers' do
    let(:num) { 2 }
    it('is nil') { expect(eligibility).to eq(UNASSESSED) }
    it('failing count') { expect(incomplete).to eq(nil) }
  end

  context 'with correct answers' do
    it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }
    it('none failing') { expect(incomplete).to eq(0) }
  end

  context 'with incorrect answers' do
    let(:eligible) { false }
    it('is ineligible') { expect(eligibility).to eq(INELIGIBLE) }
    it('some failing') { expect(incomplete).to eq(1) }
  end
end
