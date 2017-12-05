require 'rails_helper'

describe Check::Eligibility::FundingType do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
    @proposal.funding_type = 2
  end

  it '#call eligible' do
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it '#call ineligible' do
    @fund.permitted_costs = []
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it '#call ineligible proposal' do
    @proposal.funding_type = 3
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end
end
