require 'rails_helper'

describe DecisionMaker do

  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
    @db = @app.instances
    @decision_maker = DecisionMaker.first
    @fund = @db[:funds].first
  end

  it 'has many funds' do
    expect(@decision_maker.funds.count).to eq 2
  end

  it 'has many funders through funds' do
    fund2 = @db[:funds].last
    fund2.funder = create(:funder)
    fund2.save!
    assert_equal 2, @decision_maker.funders.count
  end

  it 'is valid' do
    expect(@decision_maker).to be_valid
  end

  it 'name is unique' do
    expect(build(:decision_maker, name: @decision_maker.name)).not_to be_valid
  end

end
