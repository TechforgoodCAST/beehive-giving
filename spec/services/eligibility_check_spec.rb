require 'rails_helper'

describe EligibilityCheck do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
  end

  it '#check only updates eligibility quiz keys' do
    eligibility = {
      'acme-awards-for-all-1' => { 'location' => false },
      'acme-awards-for-all-2' => { 'quiz' => false, 'location' => false },
      'acme-awards-for-all-3' => { 'quiz' => false }
    }
    match = EligibilityCheck.new(@funds, @proposal).check(eligibility)
    result = {
      'acme-awards-for-all-1' => { 'location' => false, 'quiz' => true, 'count_failing' => 0 },
      'acme-awards-for-all-2' => { 'location' => false, 'quiz' => true, 'count_failing' => 0 },
      'acme-awards-for-all-3' => { 'quiz' => true, 'count_failing' => 0 },
      'acme-awards-for-all-4' => { 'quiz' => true, 'count_failing' => 0 }
    }
    expect(match).to eq result
  end

  it '#check! updates Proposal.eligibility' do
    result = Array.new(4) do |i|
      ["acme-awards-for-all-#{i + 1}", { 'quiz' => true, 'count_failing' => 0 }]
    end.to_h
    expect(@proposal.eligibility).to be_empty
    EligibilityCheck.new(@funds, @proposal).check!
    expect(@proposal.eligibility).to eq result
  end
end
