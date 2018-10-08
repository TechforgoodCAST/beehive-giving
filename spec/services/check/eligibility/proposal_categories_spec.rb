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
    let(:category_code) { 202 }

    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }

    it 'approach' do
      reasons = {
        'Check::Eligibility::ProposalCategories' => {
          reasons: [], rating: 'approach'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'unpermitted proposal category' do
    let(:category_code) { 201 }

    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      expect(assessment.reasons).to include(
        avoid('Does not provide Capital grants')
      )
    end
  end

  context 'unknown proposal category' do
    let(:category_code) { 200 }

    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      expect(assessment.reasons).to include(
        avoid("Does not provide the type of support you're seeking")
      )
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
