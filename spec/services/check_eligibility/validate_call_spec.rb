shared_examples_for 'CheckEligibility::Child#call' do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  it '#call invalid' do
    expect { subject.call }.to raise_error ArgumentError
  end

  it '#call invalid Proposal' do
    expect { subject.call({}, @fund) }.to raise_error 'Invalid Proposal'
  end

  it '#call invalid Fund' do
    expect { subject.call(@proposal, {}) }.to raise_error 'Invalid Fund'
  end
end

describe CheckEligibility::Location do
  it_behaves_like 'CheckEligibility::Child#call'
end

describe CheckEligibility::OrgType do
  it_behaves_like 'CheckEligibility::Child#call'
end

describe CheckEligibility::Quiz do
  it_behaves_like 'CheckEligibility::Child#call'
end

describe CheckEligibility::Amount do
  it_behaves_like 'CheckEligibility::Child#call'
end

describe CheckSuitability::AmountSuitability do
  it_behaves_like 'CheckEligibility::Child#call'
end

describe CheckSuitability::LocationSuitability do
  it_behaves_like 'CheckEligibility::Child#call'
end

describe CheckSuitability::ThemeSuitability do
  it_behaves_like 'CheckEligibility::Child#call'
end
