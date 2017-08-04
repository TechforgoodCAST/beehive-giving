require 'rails_helper'

fdescribe CheckSuitability do
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

    response = {
      'acme-awards-for-all-1' => {
        'theme' => 0.5
      },
      'acme-awards-for-all-2' => {
        'theme' => 0.5
      }
    }

    expect(subject.call_each(@proposal, @funds)).to eq response
  end

  it '#call_each only returns funds that are passed in' do
    @proposal.suitability['rouge-fund'] = 0.5
    expect(subject.call_each(@proposal, @funds)).not_to have_key 'rouge-fund'
  end

  it '#call_each only returns checks that are passed in' do
    @proposal.suitability = { @funds[0].slug => { 'rouge-check' => 0.5 } }
    expect(subject.call_each(@proposal, @funds)[@funds[0].slug])
      .not_to have_key 'rouge-check'
  end

  it '#call_each! updates Proposal.suitability' do
    subject.call_each!(@proposal, @funds)

    response = {
      'acme-awards-for-all-1' => {
        'theme' => 0.5
      },
      'acme-awards-for-all-2' => {
        'theme' => 0.5
      }
    }
    expect(@proposal.suitability).to eq response
  end
end
