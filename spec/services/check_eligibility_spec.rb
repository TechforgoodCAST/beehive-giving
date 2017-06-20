require 'rails_helper'

describe CheckEligibility do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
        .create_recipient.create_registered_proposal
    @proposal = Proposal.last
    @funds = Fund.all
  end

  it '#call_each invalid' do
    expect { subject.call_each }.to raise_error ArgumentError
  end

  it '#call_each invalid Proposal' do
    expect { subject.call_each({}, @funds) }.to raise_error 'Invalid Proposal'
  end

  it '#call_each invalid Fund::ActiveRecord_Relation' do
    expect { subject.call_each(@proposal, {}) }
      .to raise_error 'Invalid Fund::ActiveRecord_Relation'
  end

  it '#call_each response' do
    Fund.first.restrictions.each do |r|
      category = r.category == 'Proposal' ? @proposal : @proposal.recipient
      create(:proposal_eligibility, category: category, restriction: r,
                                    eligible: false)
    end

    response = {
      'acme-awards-for-all-1' => {
        'location' => { 'eligible' => true },
        'org_type' => { 'eligible' => true },
        'quiz' => { 'eligible' => false, 'count_failing' => 5 }
      },
      'acme-awards-for-all-2' => {
        'location' => { 'eligible' => true },
        'org_type' => { 'eligible' => true }
      }
    }

    expect(subject.call_each(@proposal, @funds)).to eq response
  end

  it '#call_each only returns funds that are passed in' do
    @proposal.eligibility['rouge-fund'] = 'invalid'
    expect(subject.call_each(@proposal, @funds)).not_to have_key 'rouge-fund'
  end

  it '#call_each only returns checks that are passed in' do
    @proposal.eligibility = { @funds[0].slug => { 'rouge-check' => 'invalid' } }
    expect(subject.call_each(@proposal, @funds)[@funds[0].slug])
      .not_to have_key 'rouge-check'
  end

  it '#call_each! updates Proposal.eligibility' do
    Fund.first.restrictions.each do |r|
      category = r.category == 'Proposal' ? @proposal : @proposal.recipient
      create(:proposal_eligibility, category: category, restriction: r,
                                    eligible: false)
    end
    subject.call_each!(@proposal, @funds)

    response = {
      'acme-awards-for-all-1' => {
        'location' => { 'eligible' => true },
        'org_type' => { 'eligible' => true },
        'quiz' => { 'eligible' => false, 'count_failing' => 5 }
      },
      'acme-awards-for-all-2' => {
        'location' => { 'eligible' => true },
        'org_type' => { 'eligible' => true }
      }
    }
    expect(@proposal.eligibility).to eq response
  end
end
