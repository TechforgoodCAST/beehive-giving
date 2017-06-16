require 'rails_helper'

describe CheckEligibility::Setup do
  it 'invalid' do
    expect { CheckEligibility::Setup.new }.to raise_error(ArgumentError)
  end

  it 'invalid Proposal object' do
    expect { CheckEligibility::Setup.new({}) }.to raise_error('Invalid Proposal object')
  end

  it 'valid' do
    proposal = Proposal.new
    expect { CheckEligibility::Setup.new(proposal) }.not_to raise_error
  end
end
