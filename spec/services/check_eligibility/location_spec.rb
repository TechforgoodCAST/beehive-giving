require 'rails_helper'

describe CheckEligibility::Location do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  subject { CheckEligibility::Location.new(@proposal) }

  it '#call invalid' do
    expect { subject.call }.to raise_error ArgumentError
  end

  it '#call eligible' do
    expect(subject.call(@fund)).to eq 'eligible' => true
  end

  it '#call with national Proposal' do
    @proposal.affect_geo = 2
    expect(subject.call(@fund)).to eq 'eligible' => true
  end

  it '#call counties_ineligible?' do
    @fund.country_ids = []
    expect(subject.call(@fund)).to eq 'eligible' => false
  end

  it '#call national_ineligible?' do
    @fund.geographic_scale_limited = true
    @fund.national = true
    expect(subject.call(@fund)).to eq 'eligible' => false
  end

  it '#call districts_ineligible?' do
    @fund.geographic_scale_limited = true
    expect(subject.call(@fund)).to eq 'eligible' => false
  end
end
