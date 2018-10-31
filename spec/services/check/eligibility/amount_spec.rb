require 'rails_helper'

describe Check::Eligibility::Amount do
  let(:assessment) do
    build(
      :assessment,
      proposal: proposal,
      fund: build(
        :fund_with_rules,
        proposal_min_amount: min_amount,
        proposal_max_amount: max_amount
      )
    )
  end
  let(:proposal) { build(:proposal) }
  let(:min_amount) { proposal.min_amount }
  let(:max_amount) { proposal.max_amount }
  let(:eligibility) { assessment.eligibility_amount }

  before { subject.call(assessment) }

  context 'Proposal#min_amount and Proposal#max_amount within limits' do
    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    it('approach') { expect(assessment.reasons).to include(approach) }
  end

  context 'Proposal#min_amount and Proposal#max_amount outside limits' do
    let(:min_amount) { proposal.min_amount + 1 }
    let(:max_amount) { proposal.max_amount - 1 }

    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      reasons = {
        'Check::Eligibility::Amount' => {
          reasons: [
            {
              id: 'below_min',
              fund_value: '£10,000',
              proposal_value: '£10,001'
            },
            {
              id: 'above_max',
              fund_value: '£250,000',
              proposal_value: '£249,999'
            }
          ].to_set,
          rating: 'avoid'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'Proposal#min_amount less than Opportunity#proposal_min_amount' do
    let(:min_amount) { proposal.min_amount + 1 }

    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      reasons = {
        'Check::Eligibility::Amount' => {
          reasons: [{
            id: 'below_min', fund_value: '£10,000', proposal_value: '£10,001'
          }].to_set,
          rating: 'avoid'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'no Opportunity#proposal_min_amount' do
    let(:min_limited) { nil }
    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    it('approach') { expect(assessment.reasons).to include(approach) }
  end

  context 'Proposal#max_amount more than Opportunity#proposal_max_amount' do
    let(:max_amount) { proposal.max_amount - 1 }

    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      reasons = {
        'Check::Eligibility::Amount' => {
          reasons: [{
            id: 'above_max', fund_value: '£250,000', proposal_value: '£249,999'
          }].to_set,
          rating: 'avoid'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'no Opportunity#proposal_max_amount' do
    let(:max_limited) { nil }
    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    it('approach') { expect(assessment.reasons).to include(approach) }
  end

  context 'no Opportunity#proposal_min_amount and #proposal_max_amount' do
    let(:min_limited) { nil }
    let(:max_limited) { nil }
    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    it('approach') { expect(assessment.reasons).to include(approach) }
  end

  context 'Proposal seeking other type of support' do
    let(:proposal) { build(:proposal_no_funding) }

    it 'not triggered' do
      expect(subject.call(assessment)).to eq(nil)
      expect(eligibility).to eq(nil)
    end
  end

  def approach
    { 'Check::Eligibility::Amount' => {
      rating: 'approach', reasons: [{ id: 'eligible' }]
    } }
  end
end
