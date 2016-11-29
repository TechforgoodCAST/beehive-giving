require 'rails_helper'

describe Deadline do

  before(:each) do
    @app.seed_test_db.setup_funds
    @db = @app.instances
    @deadline = Deadline.first
    @fund = @db[:funds].first
  end

  it 'belongs to fund' do
    expect(@deadline.fund).to eq @fund
  end

  it 'is valid' do
    expect(@deadline).to be_valid
  end

  it 'is in future' do
    expect(build(:deadline, fund: @fund, deadline: 1.day.ago)).not_to be_valid
  end

  it 'destroyed with fund' do
    expect(Deadline.count).to eq 2
    @fund.destroy
    expect(Deadline.count).to eq 0
  end

end
