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
            "The minimum amount you're seeking (£10,000) is less than the " \
            'minimum awarded (£10,001)',
            "The maximum amount you're seeking (£250,000) is more than the " \
            'maximum awarded (£249,999)'
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
          reasons: [
            "The minimum amount you're seeking (£10,000) is less than the " \
            'minimum awarded (£10,001)'
          ].to_set,
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
          reasons: [
            "The maximum amount you're seeking (£250,000) is more than the " \
            'maximum awarded (£249,999)'
          ].to_set,
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

    it('incomplete') { expect(eligibility).to eq(INCOMPLETE) }

    it('unclear') do
      reasons = {
        'Check::Eligibility::Amount' => {
          reasons: ['Amount sought not provided'].to_set,
          rating: 'unclear'
        }
      }
      expect(assessment.reasons).to eq(reasons)
    end
  end

  def approach
    { 'Check::Eligibility::Amount' => { reasons: [], rating: 'approach' } }
  end
end
