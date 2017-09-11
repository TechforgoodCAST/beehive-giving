require 'rails_helper'

describe Check::Base do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  subject { Class.new.include(Check::Base).new }

  it '#eligible' do
    expect(subject.eligible(true)).to eq 'eligible' => true
  end

  it '#validate_call invalid' do
    expect { subject.validate_call }.to raise_error ArgumentError
  end

  it '#validate_call invalid Proposal' do
    expect { subject.validate_call({}, @fund) }
      .to raise_error 'Invalid Proposal'
  end

  it '#validate_call invalid Fund' do
    expect { subject.validate_call(@proposal, {}) }
      .to raise_error 'Invalid Fund'
  end
end
