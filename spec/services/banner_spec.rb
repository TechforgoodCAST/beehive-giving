require 'rails_helper'

describe Banner do
  let(:assessment) { instance_double(Assessment, suitability_status: status) }

  context '#background' do
    subject { described_class.new(assessment).background }

    context 'approach' do
      let(:status) { 'approach' }
      it { expect(subject).to eq('bg-light-green border-pale-green') }
    end

    context 'unclear' do
      let(:status) { 'unclear' }
      it { expect(subject).to eq('bg-light-yellow border-pale-yellow') }
    end

    context 'avoid' do
      let(:status) { 'avoid' }
      it { expect(subject).to eq('bg-light-red border-pale-red') }
    end

    context 'missing' do
      let(:status) { nil }
      it { expect(subject).to eq('bg-light-yellow border-pale-yellow') }
    end
  end

  context '#color' do
    subject { described_class.new(assessment).color }

    context 'approach' do
      let(:status) { 'approach' }
      it { expect(subject).to eq('green') }
    end

    context 'unclear' do
      let(:status) { 'unclear' }
      it { expect(subject).to eq('yellow') }
    end

    context 'avoid' do
      let(:status) { 'avoid' }
      it { expect(subject).to eq('red') }
    end

    context 'missing' do
      let(:status) { nil }
      it { expect(subject).to eq('yellow') }
    end
  end

  context '#indicator' do
    subject { described_class.new(assessment).indicator }

    context 'approach' do
      let(:status) { 'approach' }
      it { expect(subject).to eq('bg-green') }
    end

    context 'unclear' do
      let(:status) { 'unclear' }
      it { expect(subject).to eq('bg-yellow') }
    end

    context 'avoid' do
      let(:status) { 'avoid' }
      it { expect(subject).to eq('bg-red') }
    end

    context 'missing' do
      let(:status) { nil }
      it { expect(subject).to eq('bg-yellow') }
    end
  end

  context '#text' do
    subject { described_class.new(assessment).text }

    context 'approach' do
      let(:status) { 'approach' }
      it { expect(subject).to eq('Minimum standard of application met') }
    end

    context 'unclear' do
      let(:status) { 'unclear' }
      it { expect(subject).to eq('Unclear if you should apply') }
    end

    context 'avoid' do
      let(:status) { 'avoid' }
      it { expect(subject).to eq('Avoid this opportunity') }
    end

    context 'missing' do
      let(:status) { nil }
      it { expect(subject).to eq('Unclear if you should apply') }
    end
  end
end
