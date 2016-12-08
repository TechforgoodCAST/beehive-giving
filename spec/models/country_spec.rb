require 'rails_helper'
require_relative '../support/deprecated_helper'

describe Country do
  let(:deprecated) { DeprecatedHelper.new }

  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 2)
        .create_recipient
        .create_complete_proposal
        .create_registered_proposal
    @db = @app.instances
    @uk = @db[:uk]
    @uk_districts = @db[:uk_districts]
  end

  it 'has many districts' do
    expect(@uk.districts.order(:district).to_a).to eq @uk_districts
  end

  it 'has many proposals' do
    expect(@uk.proposals.count).to eq 2
  end

  it 'has many funds' do
    expect(@uk.funds.count).to eq 2
  end

  it 'has many funders through funds' do
    fund = Fund.last
    fund.funder = create(:funder)
    fund.save!
    expect(@uk.funders.count).to eq 2
  end

  it 'is valid' do
    expect(@uk).to be_valid
  end

  it 'name is unique' do
    expect(build(:country, name: @uk.name)).not_to be_valid
  end

  it 'alpha2 is unique' do
    expect(build(:country, alpha2: @uk.alpha2)).not_to be_valid
  end

  context 'deprecated' do
    it 'has many funder attributes' do
      deprecated.create_funder_attributes
      expect(@uk.funder_attributes.count).to eq 2
    end

    it 'has many profiles' do
      deprecated.create_profiles
      expect(@uk.profiles.count).to eq 2
    end

    it 'has many grants' do
      deprecated.create_grants
      expect(@uk.grants.count).to eq 2
    end
  end
end
