require 'rails_helper'

describe CheckSuitability::DurationSuitability do
  before(:each) do
    @app.seed_test_db.setup_funds(open_data: true)
        .create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  it '#call gets score from beehive-insight' do
    expect(subject.call(@proposal, @fund)).to eq 'score' => 0.1
  end
end
