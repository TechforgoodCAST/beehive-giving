require 'rails_helper'

describe Check::Suitability::Quiz do
  let(:assessment) do
    build(
      :assessment,
      fund: build(:fund, priorities: priorities),
      recipient: create(
        :recipient,
        answers: [build(
          :answer,
          criterion: priorities.first,
          eligible: eligible,
          category_type: 'Proposal'
        )]
      )
    )
  end
  let(:priorities) { build_list(:priority, num, category: 'Proposal') }
  let(:num) { 1 }
  let(:eligible) { true }
  let(:suitability) { assessment.suitability_quiz }
  let(:incomplete) { assessment.suitability_quiz_failing }

  before { subject.call(assessment) }

  context 'with incomplete answers' do
    let(:num) { 2 }

    it('is nil') { expect(suitability).to eq(UNASSESSED) }

    it('failing count') { expect(incomplete).to eq(nil) }

    it 'unclear' do
      reasons = {
        'Check::Suitability::Quiz' => {
          reasons: [
            'The priorities for this opportunity have changed, and your ' \
            'answers are incomplete'
          ].to_set,
          rating: 'unclear'
        }
      }
      expect(assessment.reasons).to eq(reasons)
    end
  end

  context 'with correct answers' do
    it('is eligible') { expect(suitability).to eq(ELIGIBLE) }

    it('none failing') { expect(incomplete).to eq(0) }

    it 'approach' do
      reasons = {
        'Check::Suitability::Quiz' => { reasons: [], rating: 'approach' }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'with incorrect answers' do
    let(:eligible) { false }

    it('is ineligible') { expect(suitability).to eq(INELIGIBLE) }

    it('some failing') { expect(incomplete).to eq(1) }

    it 'avoid' do
      reasons = {
        'Check::Suitability::Quiz' => {
          reasons: [
            'You do not meet 1 of the priorities for this opportunity'
          ].to_set,
          rating: 'avoid'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end
end
