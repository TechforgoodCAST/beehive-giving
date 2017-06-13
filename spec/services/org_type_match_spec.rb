require 'rails_helper'

describe OrgTypeMatch do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
    @org_types = OrgType.all
  end

  it '#check only updates eligibility org type keys' do
    eligibility = {
      'fund1' => { 'location' => false, 'org_type' => false },
      'fund2' => { 'quiz' => true, 'location' => false },
      'fund3' => { 'quiz' => true, 'org_type' => false }
    }
    check = OrgTypeMatch.new(@funds, @proposal).check(eligibility)
    result = {
      'fund1' => { 'location' => false },
      'fund2' => { 'quiz' => true, 'location' => false },
      'fund3' => { 'quiz' => true }
    }
    expect(check).to eq result
  end

  it 'proposal org type included in list of inclusions eligible' do
    @proposal.org_type = [@org_types[0]]
    @funds[0].org_types = [@org_types[0], @org_types[1]]
    check = OrgTypeMatch.new([@funds[0]], @proposal).check()
    result = {
      @funds[0].slug => { 'org_type' => true }
    }
    expect(check).to eq result
  end

  it 'proposal org type not included in list of inclusions ineligible' do
    @proposal.org_type = [@org_types[0]]
    @funds[0].org_types = [@org_types[1], @org_types[2]]
    check = OrgTypeMatch.new([@funds[0]], @proposal).check()
    result = {
      @funds[0].slug => { 'org_type' => true }
    }
    expect(check).to eq result
  end

end
