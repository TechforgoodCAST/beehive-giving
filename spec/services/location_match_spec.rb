require 'rails_helper'

describe LocationMatch do
  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
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

    it '#match only updates eligibility keys with location as reason' do
      eligibility = {
        'fund1' => { 'eligibile' => false, 'reason' => 'location' },
        'fund2' => { 'eligibile' => true }
      }
      match = LocationMatch.new(@funds, @proposal).match(eligibility)
      expect(match).to eq 'fund2' => { 'eligibile' => true }
    end
  end

  context 'fund seeking work in other countries' do
    it 'Fund ineligible for Proposal that does not match Fund.countries' do
      @funds.first.country_ids = [Country.last.id]
      @funds.first.save!
      expect(LocationMatch.new(@funds, @proposal).match).to eq @result
    end
  end

  context 'fund seeking work at national scale' do
    it 'fund ineligible for proposal seeking funding at national level' do
      @proposal.update!(affect_geo: 2)
      @funds.first.update!(geographic_scale: 2, geographic_scale_limited: true)
      expect(LocationMatch.new(@funds, @proposal).match).to eq @result
    end
  end

  context 'fund seeking work at a local level' do
    it 'fund ineligible with notice for local proposal no district match ' \
        'e.g. Blagrave Trust' do
      @funds.first.update!(
        geographic_scale: 0,
        geographic_scale_limited: true,
        district_ids: [District.last.id]
      )
      expect(LocationMatch.new(@funds, @proposal).match).to eq @result
    end

    it 'fund neutral with notice for national proposal'
    it 'fund eligible with notice for local proposal partial/full match'
    it 'fund neutral with notice for local proposal intersect/overlap match'
  end

  context 'fund seeking work at any level' do
    it 'fund eligible with notice for local proposal'
    it 'fund eligible with notice for national proposal'
  end
end
