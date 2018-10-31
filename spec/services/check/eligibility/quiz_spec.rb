require 'rails_helper'

describe Check::Eligibility::Quiz do
  let(:assessment) do
    build(
      :assessment,
      fund: build(:fund, restrictions: restrictions),
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
  let(:restriction_id) { restrictions.first.id }

  before { subject.call(assessment) }

  it 'not triggered if Fund missing restrictions' do
    assessment.fund.restrictions = []
    expect(subject.call(assessment)).to eq(nil)
  end

  context 'with incomplete answers' do
    let(:num) { 2 }

    it('is nil') { expect(eligibility).to eq(UNASSESSED) }

    it('failing count') { expect(incomplete).to eq(nil) }

    it 'unclear' do
      reasons = {
        'Check::Eligibility::Quiz' => {
          reasons: [{
            id: 'incomplete',
            fund_value: [restriction_id, nil],
            proposal_value: { restriction_id => true }
          }].to_set,
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
        'Check::Eligibility::Quiz' => {
          rating: 'approach',
          reasons: [{
            id: 'eligible',
            fund_value: [restriction_id],
            proposal_value: { restriction_id => true }
          }]
        }
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
          reasons: [{
            id: 'ineligible',
            fund_value: [restriction_id],
            proposal_value: { restriction_id => false }
          }].to_set,
          rating: 'avoid'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end
end
