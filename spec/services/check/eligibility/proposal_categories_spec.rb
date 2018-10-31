require 'rails_helper'

describe Check::Eligibility::ProposalCategories do
  let(:assessment) do
    build(
      :assessment,
      fund: build(:fund_with_rules),
      proposal: build(:proposal, category_code: category_code)
    )
  end
  let(:eligibility) { assessment.eligibility_proposal_categories }

  before { subject.call(assessment) }

  context 'permitted proposal category' do
    let(:category_code) { 202 } # Revenue - Core

    it 'not triggered if Fund missing proposal_categories' do
      assessment.fund.proposal_categories = []
      expect(subject.call(assessment)).to eq(nil)
    end

    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }

    it 'approach' do
      reasons = {
        'Check::Eligibility::ProposalCategories' => {
          rating: 'approach',
          reasons: [{
            id: 'grant_funding_eligible',
            fund_value: [202, 203],
            proposal_value: 202
          }]
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'unpermitted proposal category' do
    let(:category_code) { 201 } # Capital

    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      reason = {
        id: 'grant_funding_ineligible',
        fund_value: [202, 203],
        proposal_value: 201
      }
      expect(assessment.reasons).to include(avoid(reason))
    end
  end

  context 'unknown proposal category' do
    let(:category_code) { 200 }

    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      reason = {
        id: 'other_ineligible',
        fund_value: [202, 203],
        proposal_value: 200
      }
      expect(assessment.reasons).to include(avoid(reason))
    end
  end

  def avoid(msg)
    {
      'Check::Eligibility::ProposalCategories' => {
        reasons: [msg].to_set, rating: 'avoid'
      }
    }
  end
end
