require 'rails_helper'

RSpec.shared_examples 'apply_default' do
  it('indicator') { expect(subject.indicator).to eq 'bg-grey' }
  it('message')   { expect(subject.message).to have_text 'Apply' }
  it('highlight') { expect(subject.highlight).to eq nil }
end

describe Progress::Apply, type: :feature do
  subject { Progress::Apply.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#label') { expect(subject.label).to eq('Apply') }

  context 'no assessment' do
    it_behaves_like 'apply_default'
  end

  context 'incomplete' do
    let(:assessment) { OpenStruct.new(eligibility_status: INCOMPLETE) }
    it_behaves_like 'apply_default'
  end

  context 'ineligible' do
    let(:assessment) { OpenStruct.new(eligibility_status: INELIGIBLE) }
    it_behaves_like 'apply_default'
  end

  context 'eligible fund hidden' do
    let(:assessment) do
      OpenStruct.new(eligibility_status: ELIGIBLE, fund_id: 1, proposal_id: 1)
    end
    it('indicator') { expect(subject.indicator).to eq('bg-blue') }
    it('message')   { expect(subject.message).not_to have_link('Apply') }
    it('highlight') { expect(subject.highlight).to eq(nil) }
  end

  context 'eligible fund revealed' do
    let(:assessment) do
      OpenStruct.new(
        eligibility_status: ELIGIBLE, fund_id: 1, proposal_id: 1, revealed: true
      )
    end
    it('indicator') { expect(subject.indicator).to eq('bg-blue') }
    it('message')   { expect(subject.message).to have_link('Apply') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end
end
