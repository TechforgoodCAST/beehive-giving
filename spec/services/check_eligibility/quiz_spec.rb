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

  subject { CheckEligibility::Quiz.new(@proposal) }

  it '#call invalid' do
    expect { subject.call }.to raise_error ArgumentError
  end

  it '#call eligible' do
    expect(subject.call(@fund)).to eq 'eligible' => true, 'count_failing' => 0
  end

  it '#call ineligible' do
    Eligibility.update_all eligible: false
    expect(subject.call(@fund)).to eq 'eligible' => false, 'count_failing' => 5
  end

  it '#check only updates eligibility quiz keys' do
    raise StandardError, 'move to parent class'
  end

  it '#check! updates Proposal.eligibility' do
    raise StandardError, 'move to parent class'
  end
end
