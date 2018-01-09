require 'rails_helper'

describe Check::Eligibility::Amount do
  let(:assessment) do
    build(
      :assessment,
      proposal: build(:proposal, total_costs: total_costs),
      fund: build(
        :fund,
        min_amount_awarded_limited: min_limited,
        max_amount_awarded_limited: max_limited
      )
    )
  end
  let(:min_limited) { true }
  let(:max_limited) { true }
  let(:total_costs) { 5_000 }
  let(:eligibility) { assessment.eligibility_amount }

  before { subject.call(assessment) }

  context 'amount within limits' do
    it('eligible') { expect(eligibility).to eq(1) }
  end

  context 'amount less than min. amount awarded' do
    let(:total_costs) { 500 }
    it('ineligible') { expect(eligibility).to eq(0) }
  end

  context 'no min. amount awarded' do
    let(:min_limited) { false }
    let(:total_costs) { 500 }
    it('eligible') { expect(eligibility).to eq(1) }
  end

  context 'amount more than max. amount awarded' do
    let(:total_costs) { 50_000 }
    it('ineligible') { expect(eligibility).to eq(0) }
  end

  context 'no max. amount awarded' do
    let(:max_limited) { false }
    let(:total_costs) { 50_000 }
    it('eligible') { expect(eligibility).to eq(1) }
  end
end
