require 'rails_helper'

describe CheckEligibility::OrgType do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  subject { CheckEligibility::OrgType.new(@proposal) }

  it '#call invalid' do
    expect { subject.call }.to raise_error ArgumentError
  end

  it '#call eligible' do
    expect(subject.call(@fund)).to eq 'eligible' => true
  end

  it '#call ineligible' do
    @fund.permitted_org_types = []
    expect(subject.call(@fund)).to eq 'eligible' => false
  end
end