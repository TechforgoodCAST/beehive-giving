require 'rails_helper'

describe AnswersHelper do
  subject { Class.new.include(AnswersHelper).new }

  context '#yes_selected?' do
    context 'eligible and NOT inverted' do
      let(:opts) { [true, false] }
      it { expect(subject.yes_selected?(*opts)).to eq(false) }
    end

    context 'ineligible and inverted' do
      let(:opts) { [false, true] }
      it { expect(subject.yes_selected?(*opts)).to eq(false) }
    end

    context 'eligible and inverted' do
      let(:opts) { [true, true] }
      it { expect(subject.yes_selected?(*opts)).to eq(true) }
    end

    context 'ineligible and NOT inverted' do
      let(:opts) { [false, false] }
      it { expect(subject.yes_selected?(*opts)).to eq(true) }
    end

    context 'eligible arg missing' do
      let(:opts) { [nil, false] }
      it { expect(subject.yes_selected?(*opts)).to eq(nil) }
    end

    context 'inverted arg missing' do
      let(:opts) { [false, nil] }
      it { expect(subject.yes_selected?(*opts)).to eq(nil) }
    end
  end
end
