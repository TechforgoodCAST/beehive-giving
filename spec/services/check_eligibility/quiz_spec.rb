require 'rails_helper'

describe CheckEligibility::Quiz do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @proposal = Proposal.last
    @fund = Fund.last
    @fund.restrictions.each do |r|
      category = r.category == 'Proposal' ? @proposal : @proposal.recipient
      create(:proposal_eligibility, category: category, restriction: r)
    end
  end

  it '#check eligible' do
    match = CheckEligibility::Quiz.new(@proposal).check(@fund)
    expect(match).to eq 'eligible' => true, 'count_failing' => 0
  end

  it '#check ineligible' do
    Eligibility.update_all eligible: false
    match = CheckEligibility::Quiz.new(@proposal).check(@fund)
    expect(match).to eq 'eligible' => false, 'count_failing' => 5
  end

  it '#check only updates eligibility quiz keys' do
    raise StandardError, 'move to parent class'
  end

  it '#check! updates Proposal.eligibility' do
    raise StandardError, 'move to parent class'
  end
end
