require 'rails_helper'

describe OrgTypeMatch do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
    @org_types = ORG_TYPES
  end

  context 'init' do
    it 'requires fund and proposal to initialize' do
      expect { OrgTypeMatch.new }.to raise_error(ArgumentError)
      expect { OrgTypeMatch.new(@fund) }.to raise_error(ArgumentError)
      expect { OrgTypeMatch.new(@fund, @proposal) }.not_to raise_error
    end

    it 'invalid fund collection raises errror' do
      expect { OrgTypeMatch.new({}, @proposal) }
        .to raise_error('Invalid Fund object')
    end

    it 'invalid proposal object raises error' do
      expect { OrgTypeMatch.new(@fund, {}) }
        .to raise_error('Invalid Proposal object')
    end
  end
  # it 'proposal org type included in list of inclusions eligible' do
  #   @proposal.org_type = [@org_types[0]]
  #   @funds[0].org_types = [@org_types[0], @org_types[1]]
  #   check = OrgTypeMatch.new(@funds[0], @proposal).check()
  #   result = {
  #     @funds[0].slug => { 'org_type' => true }
  #   }
  #   expect(check).to eq result
  # end

  it 'proposal org type not included in list of inclusions ineligible' do
    @proposal.recipient.org_type = [@org_types[0][1]]
    @fund.permitted_org_types = [@org_types[1][1], @org_types[2][1]]
    check = OrgTypeMatch.new(@fund, @proposal).check
    expect(check).to eq "eligible" => false
  end

end
