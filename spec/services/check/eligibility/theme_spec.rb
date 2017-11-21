require 'rails_helper'

describe Check::Eligibility::Theme do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
    @t1 = Theme.first
    @t2 = Theme.second
    @t3 = Theme.third
  end

  it '#call suitable' do
    @fund.themes = [@t1]
    @proposal.themes = [@t1, @t2]
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it '#call unsuitable' do
    @fund.themes = []
    @proposal.themes = [@t1, @t2]
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it 'suitability based on related themes' do
    @t2.related = { @t1.name => 0.75 }
    @fund.themes = [@t1]
    @proposal.themes = [@t2]
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end
end