require 'rails_helper'

describe LocationMatch do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
    @result = {
      @funds.first.slug => { 'eligible' => false, 'reason' => 'location' }
    }
  end

  context 'init' do
    it 'requires funds and proposal to initialize' do
      expect { LocationMatch.new }.to raise_error(ArgumentError)
      expect { LocationMatch.new(@funds) }.to raise_error(ArgumentError)
      expect { LocationMatch.new(@funds, @proposal) }.not_to raise_error
    end

    it 'invalid funds collection raises errror' do
      expect { LocationMatch.new({}, @proposal) }
        .to raise_error('Invalid Fund::ActiveRecord_Relation')
    end

    it 'invalid proposal object raises error' do
      expect { LocationMatch.new(@funds, {}) }
        .to raise_error('Invalid Proposal object')
    end
  end

  it '#match only updates eligibility keys with location as reason' do
    eligibility = {
      'fund1' => { 'eligibile' => false, 'reason' => 'location' },
      'fund2' => { 'eligibile' => true }
    }
    match = LocationMatch.new(@funds, @proposal).match(eligibility)
    expect(match).to eq 'fund2' => { 'eligibile' => true }
  end

  it 'ineligible for Proposal that does not match Fund.countries' do
    @funds.first.country_ids = [Country.last.id]
    @funds.first.save!
    expect(LocationMatch.new(@funds, @proposal).match).to eq @result
  end

  context 'integration' do
    before(:each) do
      @db = @app.instances

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

    it 'seeking funds local' do
      @proposal.update!(affect_geo: 0, districts: [@db[:uk_districts].first])
      expect(@proposal.eligibility).not_to have_key @local.slug
      expect(@proposal.eligibility).to have_key @national.slug

      expect(@proposal.eligibility).not_to have_key @anywhere.slug
    end

    it 'seeking funds national' do
      @proposal.update!(affect_geo: 2, districts: [])
      expect(@proposal.eligibility).to have_key @local.slug
      expect(@proposal.eligibility).not_to have_key @national.slug

      expect(@proposal.eligibility).not_to have_key @anywhere.slug
    end

    it 'Proposal#initial_recommendation updates keys with location as reason' do
      eligibility = {
        @local.slug => { 'eligibile' => false, 'reason' => 'location' },
        @anywhere.slug => { 'eligibile' => true }
      }
      @proposal.update!(affect_geo: 0, districts: [@db[:uk_districts].first],
                        eligibility: eligibility)
      result = {
        'esmee' => { 'eligibile' => true },
        'ellerman' => { 'eligible' => false, 'reason' => 'location' }
      }
      expect(@proposal.eligibility).to eq result
    end
  end
end
