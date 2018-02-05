require 'rails_helper'

describe Progress::Eligibility, type: :feature do
  subject { Progress::Eligibility.new(status: status, position: 'bot') }
  let(:status) { UNASSESSED }

  it('#label') { expect(subject.label).to eq('Eligibility') }

  context 'no assessment' do
    it('indicator') { expect(subject.indicator).to eq('bg-grey bot') }
    it('message')   { expect(subject.message).to eq(nil) }
    it('highlight') { expect(subject.highlight).to eq(nil) }
  end

  context 'incomplete' do
    let(:status) { INCOMPLETE }
    it('indicator') { expect(subject.indicator).to eq('bg-blue bot') }
    it('message')   { expect(subject.message).to have_link('Complete') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end

  context 'ineligible' do
    let(:status) { INELIGIBLE }
    it('indicator') { expect(subject.indicator).to eq('bg-red bot') }
    it('message')   { expect(subject.message).to have_link('Ineligible') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end

  context 'eligible' do
    let(:status) { ELIGIBLE }
    it('indicator') { expect(subject.indicator).to eq('bg-green bot') }
    it('message')   { expect(subject.message).to have_link('Eligible') }
    it('highlight') { expect(subject.highlight).to eq(nil) }
  end
end
