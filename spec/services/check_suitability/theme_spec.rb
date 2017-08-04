require 'rails_helper'

describe CheckSuitability::Theme do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  it '#call suitable' do
    @fund.themes = [@t1]
    @proposal_themes  =[@t1, @t2]
    expect(subject.call(@proposal, @fund)).to eq 0.5
  end

  it '#call unsuitable' do
    @fund.themes = []
    expect(subject.call(@proposal, @fund)).to eq 0
  end

  it 'suitability based on related themes'

end
