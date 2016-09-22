require 'rails_helper'

describe Stage do

  before(:each) do
    @app.seed_test_db.setup_funds
    @db = @app.instances
    @stage = Stage.first
    @stage2 = Stage.last
    @fund = @db[:funds].first
  end

  it 'belongs to fund' do
    expect(@stage.fund).to eq @fund
  end

  it 'is valid' do
    expect(@stage).to be_valid
  end

  it 'has unique name' do
    @stage2.name = @stage.name
    expect(@stage2).not_to be_valid
  end

  it 'position must be greate than 0' do
    @stage.position = 0
    expect(@stage).not_to be_valid
  end

  it 'position must be unique' do
    @stage.position = 2
    expect(@stage).not_to be_valid
  end

  it 'position must be next in line' do
    @stage2.position = 3
    expect(@stage2).not_to be_valid
  end

  it 'destroyed with fund' do
    expect(Stage.count).to eq 2
    @fund.destroy
    expect(Stage.count).to eq 0
  end

end
