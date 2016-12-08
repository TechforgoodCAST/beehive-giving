require 'rails_helper'

describe Enquiry do
  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 2, open_data: true)
        .create_recipient
        .create_complete_proposal
    @db = @app.instances
    @proposal = @db[:complete_proposal]
    @fund = @db[:funds].first
    @enquiry = create(:enquiry, proposal: @proposal, fund: @fund)
  end

  it 'belongs to proposal' do
    expect(@enquiry.proposal).to eq @proposal
  end

  it 'belongs to fund' do
    expect(@enquiry.fund).to eq @fund
  end

  it 'is valid' do
    expect(@enquiry).to be_valid
  end

  it 'is invalid' do
    @enquiry.approach_funder_count = nil
    expect(@enquiry).not_to be_valid
  end

  it 'approach_funder_count defaults to 0' do
    expect(@enquiry.approach_funder_count).to eq 0
  end

  it 'is unique to proposal and fund' do
    duplicate = build(:enquiry, proposal: @proposal, fund: @fund)
    expect(duplicate).not_to be_valid

    unique = build(:enquiry, proposal: @proposal, fund: @db[:funds].last)
    expect(unique).to be_valid
  end
end
