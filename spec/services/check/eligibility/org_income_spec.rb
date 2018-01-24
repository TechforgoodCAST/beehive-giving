require 'rails_helper'

describe Check::Eligibility::OrgIncome do
  let(:assessment) do
    build(
      :assessment,
      recipient: build(:recipient, income_band: income_band, income: income),
      fund: build(
        :fund,
        min_org_income_limited: min_income,
        max_org_income_limited: max_income
      )
    )
  end
  let(:income_band) { 1 }
  let(:income) { nil }
  let(:min_income) { true }
  let(:max_income) { true }
  let(:eligibility) { assessment.eligibility_org_income }

  before { subject.call(assessment) }

  context 'Recipient with income_band' do
    context 'within limits' do
      it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end

    context 'less than min. income awarded' do
      let(:income_band) { 0 }
      it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

      context 'no min. income awarded' do
        let(:min_income) { false }
        it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
      end
    end

    context 'more than max. income awarded' do
      let(:income_band) { 3 }
      it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

      context 'no max. income awarded' do
        let(:max_income) { false }
        it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
      end
    end
  end

  context 'Recipient with income' do
    context 'income within limits' do
      let(:income) { 50_000 }
      it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end

    context 'equal to min. income awarded' do
      let(:income) { 10_000 }
      it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end

    context 'equal to max. income awarded' do
      let(:income) { 250_000 }
      it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end

    context 'less than min. income awarded' do
      let(:income) { 5_000 }
      it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

      context 'no min. income awarded' do
        let(:min_income) { false }
        it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
      end
    end

    context 'more than max. income awarded' do
      let(:income) { 500_000 }
      it('ineligible') { expect(eligibility).to eq(INELIGIBLE) }

      context 'no max. income awarded' do
        let(:max_income) { false }
        it('eligible') { expect(eligibility).to eq(ELIGIBLE) }
      end
    end
  end
end
