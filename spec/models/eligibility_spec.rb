require 'rails_helper'

describe 'Eligibility' do

  before(:each) do
    @app.seed_test_db.setup_funds(num: 2).create_recipient
    @db = @app.instances
    @recipient = @db[:recipient]
    @restriction = Restriction.first
    @eligibility = create(:eligibility, recipient: @recipient, restriction: @restriction)
  end

  it 'belongs to recipient' do
    expect(@eligibility.recipient).to eq @recipient
  end

  it 'belongs to restriction' do
    expect(@eligibility.restriction).to eq @restriction
  end

  it 'with eligible as null is invalid' do
    @eligibility.eligible = nil
    expect(@eligibility).not_to be_valid
  end

  it 'is unique to recipient and restriction' do
    expect(
      build(:eligibility, recipient: @recipient, restriction: @restriction)
    ).not_to be_valid
    expect(
      build(:eligibility, recipient: @recipient, restriction: Restriction.last)
    ).to be_valid
  end

end
