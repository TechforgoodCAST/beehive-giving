require 'rails_helper'

fdescribe Request do
  before(:all) do
    @app.seed_test_db
        .setup_funds(num: 2, open_data: true)
        .create_recipient
        .create_complete_proposal
    @db = @app.instances
    @proposal = @db[:complete_proposal]
    @fund = @db[:funds].first
    @request = create(:request, recipient: @recipient, fund: @fund)
  end

  it 'belongs to recipient' do
    expect(@request.recipient).to eq @recipient
  end

  it 'belongs to fund' do
    expect(@request.fund).to eq @fund
  end

  it 'is valid' do
    expect(@request).to be_valid
  end

  it 'is invalid' do
    @request.fund = nil
    expect(@request).not_to be_valid
  end

  it 'is unique to recipient and fund' do
    duplicate = build(:enquiry, recipient: @recipient, fund: @fund)
    expect(duplicate).not_to be_valid

    unique = build(:enquiry, recipient: @recipient, fund: @db[:funds].last)
    expect(unique).to be_valid
  end
end