require 'rails_helper'

describe CheckSuitability do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 2, open_data: true)
        .create_recipient.create_registered_proposal
    @proposal = Proposal.last
    @funds = Fund.all
    @t1 = Theme.first
    @t2 = Theme.second
    @t3 = Theme.third
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
    @funds[0].themes = [@t1]
    @funds[1].themes = [@t1, @t2]
    @proposal.themes = [@t1, @t2]
    @proposal.eligibility[@funds[1].slug]['location']['eligible'] = false

    response = {
      @funds[0].slug => {
        'theme' => {'score' => 0.5},
        'amount' => {'score' => 0.2},
        'location' => {'score' => 1},
      },
      @funds[1].slug => {
        'theme' => {'score' => 1},
        'amount' => {'score' => 0.2},
        'location' => {"score"=>-1, "reason"=>"ineligible"},
      }
    }

    expect(subject.call_each(@proposal, @funds)).to eq response
  end

  it '#call_each only returns funds that are passed in' do
    @proposal.suitability['rouge-fund'] = { 'theme' => {'score' => 0.5} }
    expect(subject.call_each(@proposal, @funds)).not_to have_key 'rouge-fund'
  end

  it '#call_each only returns checks that are passed in' do
    @proposal.suitability = { @funds[0].slug => { 'rouge-check' => {'score' => 0.5} } }
    expect(subject.call_each(@proposal, @funds)[@funds[0].slug])
      .not_to have_key 'rouge-check'
  end

  it '#call_each! updates Proposal.suitability' do
    @funds[0].themes = [@t1]
    @funds[1].themes = [@t1, @t2]
    @proposal.themes = [@t1, @t2]
    @proposal.eligibility[@funds[1].slug]['location']['eligible'] = false

    response = {
      @funds[0].slug => {
        'theme' => {'score' => 0.5},
        'amount' => {'score' => 0.2},
        'location' => {'score' => 1},
      },
      @funds[1].slug => {
        'theme' => {'score' => 1},
        'amount' => {'score' => 0.2},
        'location' => {"score"=>-1, "reason"=>"ineligible"},
      }
    }

    subject.call_each!(@proposal, @funds)
    expect(@proposal.suitability).to eq response
  end
end
