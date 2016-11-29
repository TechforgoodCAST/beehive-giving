require 'rails_helper'
require_relative '../support/deprecated_helper'

describe FundingType do

  let(:deprecated) { DeprecatedHelper.new }

  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
    @db = @app.instances
    @funding_type = FundingType.first
    @fund = @db[:funds].first
  end

  it 'has many funds' do
    expect(@funding_type.funds.count).to eq 2
  end

  it 'has many funders through funds' do
    @fund.funder = create(:funder)
    @fund.save!
    expect(@funding_type.funders.count).to eq 2
  end

  it 'is valid' do
    expect(@funding_type).to be_valid
  end

  it 'label is unique' do
    expect(build(:funding_type, label: @funding_type.label)).not_to be_valid
  end

  context 'deprecated' do
    it 'has many funder attributes' do
      deprecated.create_funder_attributes
      expect(@funding_type.funder_attributes.count).to eq 2
    end
  end

end
