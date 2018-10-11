require 'rails_helper'

describe Check::Eligibility::Quiz do
  let(:assessment) do
    build(
      :assessment,
      fund: build(
        :fund,
        themes: build_list(:theme, 1),
        restrictions: restrictions
      ),
      recipient: create(
        :recipient,
        answers: [build(
          :answer,
          criterion: restrictions.first,
          eligible: eligible,
          category_type: 'Recipient'
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

    it 'unclear' do
      reasons = {
        'Check::Eligibility::Quiz' => {
          reasons: [
            'The restrictions for the opportunity have changed, and your ' \
            'answers are incomplete'
          ].to_set,
          rating: 'unclear'
        }
      }
      expect(assessment.reasons).to eq(reasons)
    end
  end

  context 'with correct answers' do
    it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }

    it('none failing') { expect(incomplete).to eq(0) }

    it 'approach' do
      reasons = {
        'Check::Eligibility::Quiz' => { reasons: [], rating: 'approach' }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'with incorrect answers' do
    let(:eligible) { false }

    it('is ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it('some failing') { expect(incomplete).to eq(1) }

    it 'avoid' do
      reasons = {
        'Check::Eligibility::Quiz' => {
          reasons: [
            'You do not meet 1 of the restrictions for this opportunity'
          ].to_set,
          rating: 'avoid'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end
end
