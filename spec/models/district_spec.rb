require 'rails_helper'
require_relative '../support/deprecated_helper'

describe District do
  let(:deprecated) { DeprecatedHelper.new }

  before(:each) do
    @app.seed_test_db
        .setup_funds(
          num: 2,
          opts: { geographic_scale: 1, geographic_scale_limited: true }
        )
        .create_recipient
        .subscribe_recipient
        .create_complete_proposal
        .create_registered_proposal
    @db = @app.instances
    @uk = @db[:uk]
    @arun = @db[:uk_districts].first
  end

  it 'belongs to country' do
    expect(@arun.country).to eq @uk
  end

  it 'has many proposals' do
    expect(@arun.proposals.count).to eq 2
  end

  it 'has many funds' do
    expect(@arun.funds.count).to eq 2
  end

  it 'has many funders through funds' do
    fund = Fund.last
    fund.funder = create(:funder)
    fund.save!
    expect(@arun.funders.count).to eq 2
  end

  it 'is valid' do
    expect(@arun).to be_valid
  end

  it 'is unique for country' do
    expect(build(:district, name: 'Arun', country: @uk)).not_to be_valid
  end

  context 'deprecated' do
    it 'has many funder attributes' do
      deprecated.create_funder_attributes
      expect(@arun.funder_attributes.count).to eq 2
    end

    it 'has many profiles' do
      deprecated.create_profiles
      expect(@arun.profiles.count).to eq 2
    end

    it 'has many grants' do
      deprecated.create_grants
      expect(@arun.grants.count).to eq 2
    end
  end
end
