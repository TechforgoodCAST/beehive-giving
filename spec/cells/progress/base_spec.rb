require 'rails_helper'

describe Progress::Base do
  it '#label' do
    expect { subject.label }.to raise_error(NotImplementedError)
  end

  it '#indicator' do
    expect { subject.indicator }.to raise_error(NotImplementedError)
  end

  it '#message' do
    expect { subject.message }.to raise_error(NotImplementedError)
  end

  it '#highlight' do
    expect { subject.highlight }.to raise_error(NotImplementedError)
  end

  context 'without assessment' do
    it '#eligibility_status' do
      expect(subject.eligibility_status).to eq(nil)
    end

    it '#revealed' do
      expect(subject.revealed).to eq(nil)
    end
  end

  context 'with assessment' do
    subject { described_class.new(assessment: assessment) }

    let(:assessment) do
      OpenStruct.new(eligibility_status: ELIGIBLE, revealed: true)
    end

    it '#eligibility_status' do
      expect(subject.eligibility_status).to eq(ELIGIBLE)
    end

    it '#revealed' do
      expect(subject.revealed).to eq(true)
    end
  end
end
