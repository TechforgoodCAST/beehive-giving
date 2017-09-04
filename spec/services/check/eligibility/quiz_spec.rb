require 'rails_helper'

describe Check::Eligibility::Quiz do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @proposal = Proposal.last
    @fund = Fund.last
    @fund.restrictions.each do |r|
      category = r.category == 'Proposal' ? @proposal : @proposal.recipient
      create(:proposal_eligibility, category: category, restriction: r)
    end
    @fund.save
  end

  subject do
    Check::Eligibility::Quiz.new(@proposal, Fund.active)
  end

  it '#call eligible' do
    expect(subject.call(@proposal, @fund))
      .to eq 'eligible' => true, 'count_failing' => 0
  end

  it '#call ineligible' do
    Eligibility.update_all eligible: false
    expect(subject.call(@proposal, @fund))
      .to eq 'eligible' => false, 'count_failing' => 5
  end
end
