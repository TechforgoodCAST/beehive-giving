require 'rails_helper'

describe RequestCheck do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.first
    @proposal = Proposal.last
  end

  it 'min_amount_awarded checked if min_amount_awarded_limited' do
    @fund.update!(
      min_amount_awarded_limited: true,
      min_amount_awarded: @proposal.total_costs + 1
    )
    check = RequestCheck.new(@fund, @proposal).check
    expect(check).to eq 'request' => { 'eligible' => false }
  end

  it 'max_amount_awarded checked if max_amount_awarded_limited' do
    @fund.update!(
      max_amount_awarded_limited: true,
      max_amount_awarded: @proposal.total_costs - 1
    )
    check = RequestCheck.new(@fund, @proposal).check
    expect(check).to eq 'request' => { 'eligible' => false }
  end

  it 'total_costs < min_amount_awarded'
  it 'total_costs > max_amount_awarded'
  it 'permitted_costs checked not checked if ?'
  it 'Fund.permitted_costs match Proposal.funding_type'

  it 'Fund.permitted_costs do not match Proposal.funding_type' do
    check = RequestCheck.new(@fund, @proposal).check
    expect(check).to eq 'request' => { 'eligible' => false }
  end
end
