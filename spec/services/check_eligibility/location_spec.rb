require 'rails_helper'

describe CheckEligibility::Location do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  it '#call eligible' do
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it '#call with national Proposal' do
    @proposal.affect_geo = 2
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => true
  end

  it '#call counties_ineligible?' do
    @fund.country_ids = []
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it '#call national_ineligible?' do
    @fund.geographic_scale_limited = true
    @fund.national = true
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end

  it '#call districts_ineligible?' do
    @fund.geographic_scale_limited = true
    expect(subject.call(@proposal, @fund)).to eq 'eligible' => false
  end
end
