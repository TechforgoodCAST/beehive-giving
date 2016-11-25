require 'rails_helper'

describe 'Restriction' do

  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
    @db = @app.instances
    @r1 = Restriction.third
    @r2 = Restriction.last
  end

  it 'details required' do
    @r1.details = ''
    expect(@r1).not_to be_valid
  end

  it 'details are unique' do
    @r2.details = @r1.details
    expect(@r2).not_to be_valid
  end

  it 'has many funds' do
    expect(@r1.funds.count).to eq 2
  end

  it 'has many funders through funds' do
    funder = create(:funder)
    Fund.last.update_column(:funder_id, funder.id)
    expect(@r1.funders.count).to eq 2
  end

  context 'with eligibilities' do
    before(:each) do
      @app.create_recipient
      @db = @app.instances
      create(:eligibility, restriction: @r1, recipient: @db[:recipient])
      create(:eligibility, restriction: @r1, recipient: create(:recipient))
    end

    it 'has many eligibilities' do
      expect(@r1.eligibilities.count).to eq 2
    end

    it 'has many recipients through eligibilities' do
      expect(@r1.recipients.count).to eq 2
    end
  end

  it 'truthy invert'

end
