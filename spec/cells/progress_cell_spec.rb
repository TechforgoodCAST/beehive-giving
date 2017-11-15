require 'rails_helper'
require 'shared_context'

describe ProgressCell do
  include_context 'shared context'

  controller ApplicationController

  subject { cell(:progress, proposal, fund: fund).call(:show) }

  context 'Proposal' do
    it 'displays link' do
      expect(subject).to have_link 'Change'
    end

    it 'displays total_costs' do
      expect(subject).to have_text '£10,000'
    end

    it 'hides funding_type if unknown' do
      expect(subject).not_to have_text "Don't"
    end

    context 'knows funding_type' do
      before { proposal.funding_type = 1 }

      it 'displays funding_type' do
        expect(subject).to have_text 'Capital'
      end
    end

    it 'displays title' do
      expect(subject).to have_text 'Title'
    end

    context 'not complete' do
      before { proposal.state = nil }

      it 'hides title' do
        expect(subject).not_to have_text 'Title'
      end
    end
  end

  it '#steps' do
    expect(subject).to have_text 'Eligibility'
    expect(subject).to have_text 'Suitability'
    expect(subject).to have_text 'Apply'
  end
end
