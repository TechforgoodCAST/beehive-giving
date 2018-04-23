require 'rails_helper'

describe CurrentProposalCell do
  controller ApplicationController

  subject { cell(:current_proposal, proposal).call(:show) }

  let(:assessment) { create(:incomplete) }
  let(:proposal) { assessment.proposal }

  context 'no proposal' do
    let(:proposal) { nil }
    it { is_expected.to have_text('No proposal to check') }
    it { is_expected.to have_link('Sign in') }
    it { is_expected.to have_link('create an account') }
    it { is_expected.not_to have_link('Change') }
    it { is_expected.to have_css('.bg-light-yellow') }
  end

  it 'proposal not belonging to account'
  # TODO: is_expected.to have_text('No proposal selected')

  it('total_costs') { expect(subject).to have_text('£10,000') }

  it('funding_type') { expect(subject).to have_text('Capital') }

  it 'missing funding_type' do
    proposal.funding_type = 0
    expect(subject).not_to have_text('Capital')
  end

  context 'complete proposal' do
    it { is_expected.to have_text('Title') }
  end

  context 'incomplete proposal' do
    let(:proposal) { build(:incomplete_proposal) }
    it { expect(subject).to have_text('Current proposal') }
  end

  it('incomplete count') { expect(subject).to have_text('1 fund unchecked') }
end
