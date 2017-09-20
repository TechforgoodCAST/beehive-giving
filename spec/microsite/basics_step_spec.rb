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
      is_expected.not_to be_valid
    end

    it 'in list' do
      subject.funding_type = -1
      is_expected.not_to be_valid
    end
  end

  context '#total_costs' do
    it 'required' do
      subject.total_costs = nil
      is_expected.not_to be_valid
    end

    it 'is number' do
      subject.total_costs = '0'
      is_expected.not_to be_valid
    end

    it 'greater than zero' do
      subject.total_costs = 0
      is_expected.not_to be_valid
    end
  end

  context '#org_type' do
    it 'required' do
      subject.org_type = nil
      is_expected.not_to be_valid
    end

    it 'in list' do
      subject.org_type = -1
      is_expected.not_to be_valid
    end
  end

  context '#charity_number' do
    before(:each) do
      subject.charity_number = nil
    end

    it 'required if org_type 1' do
      subject.org_type = 1
      is_expected.not_to be_valid
    end

    it 'required if org_type 3' do
      subject.org_type = 3
      is_expected.not_to be_valid
    end
  end

  context '#company_number' do
    before(:each) do
      subject.company_number = nil
    end

    it 'required if org_type 2' do
      subject.org_type = 2
      is_expected.not_to be_valid
    end

    it 'required if org_type 3' do
      subject.org_type = 3
      is_expected.not_to be_valid
    end

    it 'required if org_type 5' do
      subject.org_type = 5
      is_expected.not_to be_valid
    end
  end

  it '#recipient'
  it '#proposal'
  it '#save creates Recipient with state ?'
  it '#save creates Proposal with state ?'
  it '#transition'
end
