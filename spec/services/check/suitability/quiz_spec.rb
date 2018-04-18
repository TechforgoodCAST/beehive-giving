require 'rails_helper'

describe Check::Suitability::Quiz do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_proposal
    @proposal = Proposal.last
    @fund = Fund.last
    @fund.priorities.each do |p|
      category = p.category == 'Proposal' ? @proposal : @proposal.recipient
      create(:proposal_suitability, category: category, criterion: p)
    end
    @fund.save
  end

  subject do
    Check::Suitability::Quiz.new(@proposal, Fund.active)
  end

  it '#call 100% match' do
    expect(subject.call(@proposal, @fund))
      .to eq 'score' => 1
  end

  it '#call 0% match' do
    Answer.update_all eligible: false
    expect(subject.call(@proposal, @fund))
      .to eq 'score' => 0
  end

  it '#call partial match' do
    Answer.last.update eligible: false
    expect(subject.call(@proposal, @fund))
      .to eq 'score' => 0.8
  end

  it 'no conflict with eligibility quiz' do
    @fund.restrictions.each_with_index do |r, i|
      category = r.category == 'Proposal' ? @proposal : @proposal.recipient
      create(:proposal_eligibility, category: category, criterion: r, eligible: i.odd?)
    end
    expect(subject.call(@proposal, @fund))
      .to eq 'score' => 1
  end
end
