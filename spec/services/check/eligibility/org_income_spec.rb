require 'rails_helper'

describe Check::Eligibility::OrgIncome do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
    @proposal.recipient.income = 9_000
    @proposal.recipient.income_band = 0
  end

  it '#call eligible' do
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it '#call ineligible' do
    @fund.min_org_income = 20_000
    @fund.min_org_income_limited = true
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it 'no restrictions' do
    @fund.min_org_income_limited = false
    @fund.max_org_income_limited = false
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it 'between two values' do
    @fund.min_org_income_limited = true
    @fund.min_org_income = 5_000
    @fund.max_org_income_limited = true
    @fund.max_org_income = 15_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it 'outside two values' do
    @fund.min_org_income_limited = true
    @fund.min_org_income = 15_000
    @fund.max_org_income_limited = true
    @fund.max_org_income = 50_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it 'between two values based on band' do
    @proposal.recipient.income = nil
    @proposal.recipient.income_band = 1
    @fund.min_org_income_limited = true
    @fund.min_org_income = 5_000
    @fund.max_org_income_limited = true
    @fund.max_org_income = 15_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it 'on the edge of a band' do
    @proposal.recipient.income = nil
    @proposal.recipient.income_band = 3
    @fund.max_org_income_limited = true
    @fund.max_org_income = 1_000_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it 'on the edge of a band minimum' do
    @proposal.recipient.income = nil
    @proposal.recipient.income_band = 3
    @fund.min_org_income_limited = true
    @fund.min_org_income = 10_000_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it 'outside two values based on band' do
    @proposal.recipient.income = nil
    @proposal.recipient.income_band = 1
    @fund.min_org_income_limited = true
    @fund.min_org_income = 150_000
    @fund.max_org_income_limited = true
    @fund.max_org_income = 200_000
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end
end
