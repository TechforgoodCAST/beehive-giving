require 'rails_helper'

describe CheckEligibility::Amount do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  it '#call eligible' do
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it '#call ineligible' do
    @fund.min_amount_awarded = 20_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it 'no restrictions' do
    @fund.min_amount_awarded_limited = false
    @fund.max_amount_awarded_limited = false
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it 'between two values' do
    @fund.min_amount_awarded_limited = true
    @fund.min_amount_awarded = 5_000
    @fund.max_amount_awarded_limited = true
    @fund.max_amount_awarded = 15_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it 'outside two values' do
    @fund.min_amount_awarded_limited = true
    @fund.min_amount_awarded = 15_000
    @fund.max_amount_awarded_limited = true
    @fund.max_amount_awarded = 50_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end
end
