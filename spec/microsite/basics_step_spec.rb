require 'rails_helper'

describe BasicsStep do
  subject do
    BasicsStep.new(
      funding_type: 0,
      total_costs: 10_000,
      org_type: ORG_TYPES[4][1]
    )
  end

  context '#funding_type' do
    it 'required' do
      subject.funding_type = nil
      expect(subject).not_to be_valid
    end

    it 'in list' do
      subject.funding_type = -1
      expect(subject).not_to be_valid
    end
  end

  context '#total_costs' do
    it 'required' do
      subject.total_costs = nil
      expect(subject).not_to be_valid
    end

    it 'is number' do
      subject.total_costs = '-1.1'
      expect(subject).not_to be_valid
    end

    it 'greater than zero' do
      subject.total_costs = -1.1
      expect(subject).not_to be_valid
    end
  end

  context '#org_type' do
    it '#org_type required' do
      subject.org_type = nil
      expect(subject).not_to be_valid
    end

    it 'in list' do
      subject.org_type = -1
      expect(subject).not_to be_valid
    end
  end

  it '#save creates Recipient with state ?'
  it '#save creates Proposal with state ?'
  it '#transition'
end
