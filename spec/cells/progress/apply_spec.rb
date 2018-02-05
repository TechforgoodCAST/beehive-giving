require 'rails_helper'

RSpec.shared_examples 'default' do
  it('indicator') { expect(subject.indicator).to eq 'top bg-grey' }
  it('message')   { expect(subject.message).to have_text 'Apply' }
  it('highlight') { expect(subject.highlight).to eq nil }
end

describe Progress::Apply, type: :feature do
  subject { Progress::Apply.new(opts) }
  let(:opts) do
    {
      fund: build(:fund, id: 1),
      proposal: build(:proposal, id: 1),
      status: status,
      position: 'top'
    }
  end
  let(:status) { UNASSESSED }

  it('#label') { expect(subject.label).to eq('Apply') }

  context 'no assessment' do
    it_behaves_like 'default'
  end

  context 'incomplete' do
    let(:status) { INCOMPLETE }
    it_behaves_like 'default'
  end

  context 'ineligible' do
    let(:status) { INELIGIBLE }
    it_behaves_like 'default'
  end

  context 'eligible' do
    let(:status) { ELIGIBLE }
    it('indicator') { expect(subject.indicator).to eq('top bg-blue') }
    it('message')   { expect(subject.message).to have_link('Apply') }
    it('highlight') { expect(subject.highlight).to eq('bg-light-blue') }
  end
end
