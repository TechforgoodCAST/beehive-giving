require 'rails_helper'

RSpec.shared_examples 'reveal_default' do
  it('indicator') { expect(subject.indicator).to eq('top bot bg-grey') }
  it('message')   { expect(subject.message).to have_text('Reveal') }
  it('highlight') { expect(subject.highlight).to eq(nil) }
end

describe Progress::Reveal, type: :feature do
  subject { Progress::Reveal.new(assessment: assessment, position: 'top bot') }
  let(:assessment) { nil }

  it('#label') { expect(subject.label).to eq('Reveal fund identity') }

  context 'no assessment' do
    it_behaves_like 'reveal_default'
  end

  context 'incomplete' do
    let(:assessment) { OpenStruct.new(eligibility_status: INCOMPLETE) }
    it_behaves_like 'reveal_default'
  end

  context 'ineligible' do
    let(:assessment) { OpenStruct.new(eligibility_status: INELIGIBLE) }
    it_behaves_like 'reveal_default'
    it 'message' do
      expect(subject.message).to have_link('Reveal', class: 'blue border-blue')
    end
  end

  context 'eligible fund hidden' do
    let(:assessment) { OpenStruct.new(eligibility_status: ELIGIBLE) }
    it('indicator') { expect(subject.indicator).to eq('top bot bg-blue') }
    it('message') do
      expect(subject.message).to have_link('Reveal', class: 'white bg-blue')
    end
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end

  context 'eligible fund revealed' do
    let(:assessment) do
      OpenStruct.new(eligibility_status: ELIGIBLE, revealed: true)
    end
    it_behaves_like 'reveal_default'
    it('message') { expect(subject.message).to have_text('Revealed') }
  end
end
