require 'rails_helper'

describe Theme do
  before(:each) do
    @app.create_simple_fund num: 2
    @t1 = Theme.first
    @t2 = Theme.second
    @t3 = Theme.third
    @t2.update parent: @t1
    @t3.update parent: @t1
  end

  it 'valid with parent' do
    expect(@t2).to be_valid
  end

  it 'valid without parent' do
    expect(@t1).to be_valid
  end

  it 'belongs to parent' do
    expect(@t2.parent).to eq @t1
  end

  it '.name is unique' do
    @t2.name = @t1.name
    expect(@t2).not_to be_valid
  end

  it 'has many fund_themes' do
    @t1.update funds: [Fund.first, Fund.second]
    expect(@t1.fund_themes.count).to eq 2
  end

  it 'has many funds' do
    @t1.update funds: [Fund.first, Fund.second]
    expect(@t1.funds.count).to eq 2
  end

  it '.related can be empty' do
    @t1.related = {}
    expect(@t1).to be_valid
  end

  it '.related must be Hash' do
    @t1.related = 'string'
    expect(@t1).not_to be_valid

    @t1.related = {}
    expect(@t1).to be_valid
  end

  it '.related must have valid keys' do
    @t1.related = { 'missing' => 1 }
    expect(@t1).not_to be_valid
  end

  it '.related value must be Float or Integer' do
    ['', [], {}].each do |val|
      @t1.related = { @t1.name => val }
      expect(@t1).not_to be_valid
    end

    [1, 1.0].each do |val|
      @t1.related = { @t1.name => val }
      @t1.reload
      expect(@t1).to be_valid
    end
  end

  it 'destroys fund_themes' do
    @t1.destroy
    expect(FundTheme.count).to eq 4
    Theme.destroy_all
    expect(FundTheme.count).to eq 0
  end
end
