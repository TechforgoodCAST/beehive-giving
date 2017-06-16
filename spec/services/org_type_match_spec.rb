require 'rails_helper'

describe OrgTypeMatch do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
    @org_types = ORG_TYPES
  end

  # TODO: refactor move to parent class
  context 'init' do
    it 'requires fund and proposal to initialize' do
      expect { OrgTypeMatch.new }.to raise_error(ArgumentError)
      expect { OrgTypeMatch.new(@proposal) }.not_to raise_error
    end

    it 'invalid proposal object raises error' do
      expect { OrgTypeMatch.new({}) }
        .to raise_error('Invalid Proposal object')
    end
  end

  it 'proposal org type not included in list of inclusions ineligible' do
    @proposal.recipient.org_type = [@org_types[0][1]]
    @fund.permitted_org_types = [@org_types[1][1], @org_types[2][1]]
    check = OrgTypeMatch.new(@proposal).check(@fund)
    expect(check).to eq 'eligible' => false
  end
end
