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

    it('eligible') { expect(eligibility).to eq(ELIGIBLE) }

    it 'approach' do
      reasons = {
        'Check::Eligibility::RecipientCategories' => {
          reasons: [], rating: 'approach'
        }
      }
      expect(assessment.reasons).to include(reasons)
    end
  end

  context 'unpermitted recipient category' do
    let(:category_code) { 302 } # A company
    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }
    it('avoid') { expect(assessment.reasons).to include(avoid) }
  end

  context 'unknown proposal category' do
    let(:category_code) { 0 }
    it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }
    it('avoid') { expect(assessment.reasons).to include(avoid) }
  end

  def avoid
    {
      'Check::Eligibility::RecipientCategories' => {
        reasons: ['Only supports the following types of recipient: An ' \
                  'unregistered charity and A charitable organisation'].to_set,
        rating: 'avoid'
      }
    }
  end
end
