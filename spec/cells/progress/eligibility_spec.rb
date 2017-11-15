require 'rails_helper'
require 'shared_context'

describe Progress::Eligibility, type: :feature do
  include_context 'shared context'

  subject do
    Progress::Eligibility.new(proposal: proposal, fund: fund, position: 'bot')
  end

  it('#label') { expect(subject.label).to eq 'Eligibility' }

  context 'unchecked' do
    it('indicator') { expect(subject.indicator).to eq 'bg-blue bot' }
    it('message')   { expect(subject.message).to have_link 'Complete' }
    it('highlight') { expect(subject.highlight).to eq 'bg-light-blue' }
  end

  context 'ineligible' do
    let(:eligibility) { { quiz: { eligible: false } } }

    it('indicator') { expect(subject.indicator).to eq 'bg-red bot' }
    it('message')   { expect(subject.message).to have_link 'Ineligible' }
    it('highlight') { expect(subject.highlight).to eq 'bg-light-blue' }
  end

  context 'eligible' do
    let(:eligibility) { { quiz: { eligible: true } } }

    it('indicator') { expect(subject.indicator).to eq 'bg-green bot' }
    it('message')   { expect(subject.message).to have_link 'Eligible' }
    it('highlight') { expect(subject.highlight).to eq nil }
  end
end
