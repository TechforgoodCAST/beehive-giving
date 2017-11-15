require 'rails_helper'
require 'shared_context'

describe Progress::Apply, type: :feature do
  include_context 'shared context'

  subject do
    Progress::Apply.new(proposal: proposal, fund: fund, position: 'top')
  end

  it('#label') { expect(subject.label).to eq 'Apply' }

  context 'ineligible' do
    let(:eligibility) { { quiz: { eligible: false } } }

    it('indicator') { expect(subject.indicator).to eq 'top bg-grey' }
    it('message')   { expect(subject.message).to have_text 'Apply' }
    it('highlight') { expect(subject.highlight).to eq nil }
  end

  context 'eligible' do
    let(:eligibility) { { quiz: { eligible: true } } }

    it('indicator') { expect(subject.indicator).to eq 'top bg-blue' }
    it('message')   { expect(subject.message).to have_link 'Apply' }
    it('highlight') { expect(subject.highlight).to eq 'bg-light-blue' }
  end
end
