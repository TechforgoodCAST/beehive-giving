require 'rails_helper'

describe ProgressCell do
  controller ApplicationController

  subject { cell(:progress, assessment).call(:show) }
  let(:assessment) do
    build(
      :assessment,
      proposal: build(:complete_proposal, id: 1, suitability: { 'fund' => {} }),
      fund: build(:fund, id: 1, slug: 'fund')
    )
  end

  context 'current proposal' do
    it('shows link') { expect(subject).to have_link('Change') }

    it('shows total_costs') { expect(subject).to have_text('£10,000') }

    it('shows title') { expect(subject).to have_text('Title') }

    it 'hides unknown funding_type' do
      expect(subject).not_to have_text("Don't")
    end

    context 'with funding_type' do
      before { assessment.proposal.funding_type = 1 }
      it('shows funding_type') { expect(subject).to have_text('Capital') }
    end

    context 'incomplete' do
      before { assessment.proposal.state = nil }
      it('hides title') { expect(subject).not_to have_text('Title') }
    end
  end

  it 'has #steps' do
    expect(subject).to have_text('Eligibility')
    expect(subject).to have_text('Suitability')
    expect(subject).to have_text('Apply')
  end

  context 'fund stub' do
    before { assessment.fund.state = 'stub' }

    it 'has #steps' do
      expect(subject).to have_text('Request')
      expect(subject).to have_text('Eligibility')
      expect(subject).to have_text('Suitability')
      expect(subject).to have_text('Apply')
    end
  end

  context 'revealed' do
    it 'has #steps' do
      expect(subject).not_to have_text('Reveal')
    end
  end

  context 'subscribed' do
    it 'has #steps' do
      expect(subject).not_to have_text('Reveal')
    end
  end

  context 'featured' do
    it 'has #steps' do
      expect(subject).not_to have_text('Reveal')
    end
  end
end
