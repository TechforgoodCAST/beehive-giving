require 'rails_helper'

describe Rating::Base do
  let(:reason) { {} }
  subject { Class.new.include(Rating::Base).new(1, reason) }

  context '#indicator' do
    it('default') { expect(subject.indicator).to eq('grey') }

    context 'avoid' do
      let(:reason) { { 'rating' => 'avoid' } }
      it { expect(subject.indicator).to eq('red') }
    end

    context 'unclear' do
      let(:reason) { { 'rating' => 'unclear' } }
      it { expect(subject.indicator).to eq('yellow') }
    end

    context 'approach' do
      let(:reason) { { 'rating' => 'approach' } }
      it { expect(subject.indicator).to eq('green') }
    end
  end

  context '#link' do
    it('default') { expect(subject.link).to eq(nil) }
  end

  context '#message' do
    it('default') { expect(subject.message).to eq(nil) }

    context 'multiple reasons' do
      let(:reason) { { 'reasons' => %w[one two] } }
      it { expect(subject.message).to eq('one • two') }
    end
  end
end
