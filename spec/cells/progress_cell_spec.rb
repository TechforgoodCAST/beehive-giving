require 'rails_helper'

RSpec.shared_examples 'steps_default' do
  it 'shows #steps' do
    expect(subject.all('.bot + h5')[0]).to have_text('Eligibility')
    expect(subject.all('.bot.top + h5')[0]).to have_text('Suitability')
    expect(subject.all('.top + h5')[1]).to have_text('Apply')
  end

  it 'hides #steps' do
    expect(subject).not_to have_text('Update fund details')
    expect(subject).not_to have_text('Reveal fund identity')
  end
end

describe ProgressCell do
  controller ApplicationController

  subject { cell(:progress, assessment, options).call(:show) }
  let(:assessment) do
    build(
      :assessment,
      proposal: build(:proposal, id: 1, suitability: { 'fund' => {} }),
      fund: build(:fund, id: 1, slug: 'fund')
    )
  end
  let(:options) { {} }

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

  it 'shows #steps' do
    expect(subject.all('.bot + h5')[0]).to have_text('Eligibility')
    expect(subject.all('.bot.top + h5')[0]).to have_text('Suitability')
    expect(subject.all('.bot.top + h5')[1]).to have_text('Reveal fund identity')
    expect(subject.all('.top + h5')[2]).to have_text('Apply')
  end

  it 'hides #steps' do
    expect(subject).not_to have_text('Update fund details')
  end

  context 'fund stub' do
    before { assessment.fund.state = 'stub' }

    it 'shows #steps' do
      expect(subject.all('.bot + h5')[0]).to have_text('Update fund details')
      expect(subject.all('.bot.top + h5')[0]).to have_text('Eligibility')
      expect(subject.all('.bot.top + h5')[1]).to have_text('Suitability')
      expect(subject.all('.top + h5')[2]).to have_text('Apply')
    end

    it 'hides #steps' do
      expect(subject).not_to have_text('Reveal fund identity')
    end
  end

  context 'revealed' do
    before { assessment.revealed = true }
    it_behaves_like 'steps_default'
  end

  context 'subscribed' do
    let(:options) { { subscribed: true } }
    it_behaves_like 'steps_default'
  end

  context 'featured' do
    before { assessment.fund.featured = true }
    it_behaves_like 'steps_default'

    context 'eligible' do
      before { assessment.eligibility_status = ELIGIBLE }
      it { is_expected.to have_link('Apply') }
    end
  end
end
