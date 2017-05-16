require 'rails_helper'

feature LocationMatch do
  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 3, open_data: true)
        .tag_funds
        .create_recipient
        .with_user
        .create_complete_proposal
        .sign_in
    @db = @app.instances
  end

  scenario 'Proposal for local area marked ineligible for national Funds ' \
           'and Funds outside of area' do
    @proposal = @db[:complete_proposal]
    @proposal.update!(affect_geo: 2, district_ids: [])

    @db[:funds][0].update!(geographic_scale_limited: true)
    @db[:funds][1].update!(geographic_scale_limited: true, geographic_scale: 2)

    @proposal.initial_recommendation

    result = {
      'acme-awards-for-all-1' => { 'eligible' => false, 'reason' => 'location' },
      'acme-awards-for-all-2' => { 'eligible' => false, 'reason' => 'location' }
    }

    expect(@proposal.eligibility).to eq result
  end
end
