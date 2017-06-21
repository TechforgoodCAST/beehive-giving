require 'rails_helper'

describe CheckEligibility::Location do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @db = @app.instances
    @funds = Fund.all
    @proposal = Proposal.last

    @local = @funds[0]
    @local.update!(
      slug: 'blagrave',
      geographic_scale_limited: true, national: false,
      countries: [@db[:uk]], districts: [@db[:uk_districts].first]
    )

    @anywhere = @funds[1]
    @anywhere.update!(
      slug: 'esmee',
      geographic_scale_limited: false, national: false,
      countries: [@db[:uk]], district_ids: []
    )

    @national = @funds[2]
    @national.update!(
      slug: 'ellerman',
      geographic_scale_limited: true, national: true,
      countries: [@db[:uk]], districts: []
    )
  end

  it 'local Proposal' do
    @proposal.update!(affect_geo: 0, districts: [@db[:uk_districts].first])
    expect(subject.call(@proposal, @local)).to eq 'eligible' => true
    expect(subject.call(@proposal, @national)).to eq 'eligible' => false
    expect(subject.call(@proposal, @anywhere)).to eq 'eligible' => true
  end

  it 'national Proposal' do
    @proposal.update!(affect_geo: 2, districts: [])
    expect(subject.call(@proposal, @local)).to eq 'eligible' => true
    expect(subject.call(@proposal, @national)).to eq 'eligible' => true
    expect(subject.call(@proposal, @anywhere)).to eq 'eligible' => true
  end

  it '#call countries_ineligible?' do
    @local.country_ids = []
    expect(subject.call(@proposal, @local)).to eq 'eligible' => false
  end

  it '#call districts_ineligible?' do
    @anywhere.geographic_scale_limited = true
    expect(subject.call(@proposal, @anywhere)).to eq 'eligible' => false
  end
end
