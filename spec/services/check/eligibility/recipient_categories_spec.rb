require 'rails_helper'

describe Check::Eligibility::RecipientCategories do
  let(:assessment) do
    build(
      :assessment,
      fund: build(:fund_with_rules),
      recipient: build(:recipient, category_code: category_code)
    )
  end
  let(:eligibility) { assessment.eligibility_recipient_categories }

  before { subject.call(assessment) }

  context 'permitted recipient category' do
    let(:category_code) { 301 } # A charitable organisation

    it 'not triggered if Fund missing recipient_categories' do
      assessment.fund.recipient_categories = []
      expect(subject.call(assessment)).to eq(nil)
    end

    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }

    it 'approach' do
      reasons = {
        'Check::Eligibility::RecipientCategories' => {
          rating: 'approach',
          reasons: [{
            id: 'eligible', fund_value: [203, 301], proposal_value: 301
          }]
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'unpermitted recipient category' do
    let(:category_code) { 302 } # A company
    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }
    it 'avoid' do
      reason = { id: 'ineligible', fund_value: [203, 301], proposal_value: 302 }
      expect(assessment.reasons).to include(avoid(reason))
    end
  end

  context 'unknown proposal category' do
    let(:category_code) { 0 }
    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }
    it 'avoid' do
      reason = { id: 'ineligible', fund_value: [203, 301], proposal_value: 0 }
      expect(assessment.reasons).to include(avoid(reason))
    end
  end

  def avoid(msg)
    {
      'Check::Eligibility::RecipientCategories' => {
        reasons: [msg].to_set, rating: 'avoid'
      }
    }
  end
end
