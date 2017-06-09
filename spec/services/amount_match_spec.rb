require 'rails_helper'

fdescribe AmountMatch do
  before(:each) do
    @app.seed_test_db.setup_funds
        .create_recipient.create_registered_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
  end

  it 'if amount requested is in bucket give score of bucket' do
    amount = AmountMatch.new(@funds, @proposal)
    expect(amount.match).to eq @funds.first.slug => 0.2
  end

  it 'if amount requested is in a zero bucket give zero' do
    @proposal.income = 1_000
    amount = AmountMatch.new(@funds, @proposal)
    expect(amount.match).to eq @funds.first.slug => 0
  end
end
