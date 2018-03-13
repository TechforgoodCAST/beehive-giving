require 'rails_helper'

describe Progress::Eligibility, type: :feature do
  subject { Progress::Eligibility.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#label') { expect(subject.label).to eq('Eligibility') }

  context 'no assessment' do
    it('indicator') { expect(subject.indicator).to eq('bg-grey') }
    it('message')   { expect(subject.message).to eq(nil) }
    it('highlight') { expect(subject.highlight).to eq(nil) }
  end

  context 'incomplete' do
    let(:assessment) { OpenStruct.new(eligibility_status: INCOMPLETE) }
    it('indicator') { expect(subject.indicator).to eq('bg-blue') }
    it('message')   { expect(subject.message).to have_link('Complete') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end

  context 'ineligible' do
    let(:assessment) { OpenStruct.new(eligibility_status: INELIGIBLE) }
    it('indicator') { expect(subject.indicator).to eq('bg-red') }
    it('message')   { expect(subject.message).to have_link('Ineligible') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end

  context 'eligible' do
    let(:assessment) { OpenStruct.new(eligibility_status: ELIGIBLE) }
    it('indicator') { expect(subject.indicator).to eq('bg-green') }
    it('message')   { expect(subject.message).to have_link('Eligible') }
    it('highlight') { expect(subject.highlight).to eq(nil) }
  end
end
