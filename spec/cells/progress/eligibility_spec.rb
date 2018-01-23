require 'rails_helper'

describe Progress::Eligibility, type: :feature do
  subject { Progress::Eligibility.new(assessment: assessment, position: 'bot') }
  let(:assessment) { nil }

  it('#label') { expect(subject.label).to eq('Eligibility') }

  context 'no assessment' do
    it('indicator') { expect(subject.indicator).to eq('bg-grey bot') }
    it('message')   { expect(subject.message).to eq(nil) }
    it('highlight') { expect(subject.highlight).to eq(nil) }
  end

  context 'incomplete' do
    let(:assessment) { build(:assessment) }
    it('indicator') { expect(subject.indicator).to eq('bg-blue bot') }
    it('message')   { expect(subject.message).to have_link('Complete') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end

  context 'ineligible' do
    let(:assessment) { build(:ineligible) }

    it('indicator') { expect(subject.indicator).to eq('bg-red bot') }
    it('message')   { expect(subject.message).to have_link('Ineligible') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end

  context 'eligible' do
    let(:assessment) { build(:eligible) }

    it('indicator') { expect(subject.indicator).to eq('bg-green bot') }
    it('message')   { expect(subject.message).to have_link('Eligible') }
    it('highlight') { expect(subject.highlight).to eq(nil) }
  end
end
