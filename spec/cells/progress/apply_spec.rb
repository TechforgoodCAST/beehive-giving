require 'rails_helper'

RSpec.shared_examples 'default' do
  it('indicator') { expect(subject.indicator).to eq 'top bg-grey' }
  it('message')   { expect(subject.message).to have_text 'Apply' }
  it('highlight') { expect(subject.highlight).to eq nil }
end

describe Progress::Apply, type: :feature do
  subject { Progress::Apply.new(assessment: assessment, position: 'top') }
  let(:assessment) { build(:assessment) }

  it('#label') { expect(subject.label).to eq('Apply') }

  context 'no assessment' do
    let(:assessment) { nil }
    it_behaves_like 'default'
  end

  context 'incomplete' do
    it_behaves_like 'default'
  end

  context 'ineligible' do
    let(:assessment) { build(:ineligible) }
    it_behaves_like 'default'
  end

  context 'eligible' do
    let(:assessment) do
      build(
        :eligible,
        fund: build(:fund, id: 1),
        proposal: build(:proposal, id: 1)
      )
    end

    it('indicator') { expect(subject.indicator).to eq('top bg-blue') }
    it('message')   { expect(subject.message).to have_link('Apply') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end
end
