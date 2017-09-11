require 'rails_helper'

describe Check::Suitability::OrgType do
  before(:each) do
    @app.seed_test_db.setup_funds(open_data: true)
        .create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  it '#call suitable' do
    expect(subject.call(@proposal, @fund)).to eq 'score' => 0.41500000000000004
  end

  it '#call unsuitable' do
    @proposal.recipient.org_type = -1
    expect(subject.call(@proposal, @fund)).to eq 'score' => 0
  end
end
