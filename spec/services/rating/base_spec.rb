require 'rails_helper'

describe Rating::Base do
  let(:reasons) { {} }
  subject { Class.new.include(Rating::Base).new(1, reasons) }

  context '#indicator' do
    it('default') { expect(subject.indicator).to eq('grey') }

    context 'avoid' do
      let(:reasons) { { 'rating' => 'avoid' } }
      it { expect(subject.indicator).to eq('red') }
    end

    context 'unclear' do
      let(:reasons) { { 'rating' => 'unclear' } }
      it { expect(subject.indicator).to eq('yellow') }
    end

    context 'approach' do
      let(:reasons) { { 'rating' => 'approach' } }
      it { expect(subject.indicator).to eq('green') }
    end
  end

  context '#link' do
    it('default') { expect(subject.link).to eq(nil) }
  end

  context '#messages' do
    it('default') { expect(subject.messages).to eq(nil) }
  end
end
