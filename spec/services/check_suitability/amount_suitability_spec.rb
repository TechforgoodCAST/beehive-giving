require 'rails_helper'

describe CheckSuitability::AmountSuitability do
  before(:each) do
    @app.seed_test_db.setup_funds(open_data: true)
        .create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
    @t1 = Theme.first
    @t2 = Theme.second
    @t3 = Theme.third
  end

  it '#call suitable' do
    expect(subject.call(@proposal, @fund)).to eq 'score' => 0.2
  end

  it '#call unsuitable' do
    @proposal.total_costs = 1_000
    expect(subject.call(@proposal, @fund)).to eq 'score' => 0
  end
end
