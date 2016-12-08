require 'rails_helper'

describe Outcome do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
    @db = @app.instances
    @outcome = Outcome.first
    @fund = @db[:funds].first
  end

  it 'has many funds' do
    expect(@outcome.funds.count).to eq 2
  end

  it 'has many funders through funds' do
    @fund.funder = create(:funder)
    @fund.save!
    expect(@outcome.funders.count).to eq 2
  end

  it 'is valid' do
    expect(@outcome).to be_valid
  end

  it 'outcome is unique' do
    expect(build(:outcome, outcome: @outcome.outcome)).not_to be_valid
  end
end
