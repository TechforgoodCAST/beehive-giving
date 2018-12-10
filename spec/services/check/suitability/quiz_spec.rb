require 'rails_helper'

describe Check::Suitability::Quiz do
  let(:assessment) do
    country = build(:country)
    build(
      :assessment,
      fund: build(:fund, priorities: priorities),
      proposal: create(
        :proposal,
        answers: [build(
          :answer,
          criterion: priorities.first,
          eligible: eligible,
          category_type: 'Proposal'
        )],
        children: false,
        countries: [country],
        districts: [build(:district, country: country)],
        themes: [build(:theme)]
      )
    )
  end
  let(:priorities) { build_list(:priority, num, category: 'Proposal') }
  let(:num) { 1 }
  let(:eligible) { true }
  let(:suitability) { assessment.suitability_quiz }
  let(:incomplete) { assessment.suitability_quiz_failing }
  let(:priority_id) { priorities.first.id }

  before { subject.call(assessment) }

  it 'not triggered if Fund missing priorities' do
    assessment.fund.priorities = []
    expect(subject.call(assessment)).to eq(nil)
  end

  context 'with incomplete answers' do
    let(:num) { 2 }

    it('is nil') { expect(suitability).to eq(UNASSESSED) }

    it('failing count') { expect(incomplete).to eq(nil) }

    it 'unclear' do
      reasons = {
        'Check::Suitability::Quiz' => {
          reasons: [{
            id: 'incomplete',
            fund_value: [priority_id, nil],
            proposal_value: { priority_id => true }
          }].to_set,
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
        'Check::Suitability::Quiz' => {
          reasons: [{
            id: 'eligible',
            fund_value: [priority_id],
            proposal_value: { priority_id => true }
          }].to_set,
          rating: 'approach'
        }
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
          reasons: [{
            id: 'ineligible',
            fund_value: [priority_id],
            proposal_value: { priority_id => false }
          }].to_set,
          rating: 'avoid'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end
end
