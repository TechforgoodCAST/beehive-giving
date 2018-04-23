require 'rails_helper'

describe Check::Suitability::Location do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
    @db = @app.instances

    @local = @funds[0]
    @local.geo_area.update!(
      countries: [@db[:uk]],
      districts: [@db[:uk_districts].first]
    )
    @local.update!(
      slug: 'blagrave',
      geographic_scale_limited: true, national: false,
    )

    @anywhere = @funds[1]
    @anywhere.geo_area.update!(
      countries: [@db[:uk]],
      districts: []
    )
    @anywhere.update!(
      slug: 'esmee',
      geographic_scale_limited: false, national: false,
    )

    @national = @funds[2]
    @national.geo_area.update!(
      countries: [@db[:uk]],
      districts: []
    )
    @national.update!(
      slug: 'ellerman',
      geographic_scale_limited: true, national: true,
    )
  end

  it 'ineligble set to 0' do
    @proposal.eligibility = {
      @anywhere.slug => { 'location' => { 'eligible' => false } }
    }
    result = { 'score' => 0, 'reason' => 'ineligible' }
    expect(subject.call(@proposal, @anywhere)).to eq result
  end

  context 'proposal national' do
    before(:each) do
      @proposal.update! affect_geo: 2, district_ids: []
      @proposal.update_column :eligibility, {}
    end

    it '<> fund anywhere' do
      result = { 'score' => 1, 'reason' => 'anywhere' }
      expect(subject.call(@proposal, @anywhere)).to eq result
    end

    it '<> fund local' do
      result = { 'score' => 0, 'reason' => 'overlap' }
      expect(subject.call(@proposal, @local)).to eq result
    end

    it '<> fund national' do
      result = { 'score' => 1, 'reason' => 'national' }
      expect(subject.call(@proposal, @national)).to eq result
    end
  end

  context 'proposal exact' do
    before(:each) do
      @proposal.update! districts: [@db[:uk_districts].first]
      @proposal.update_column :eligibility, {}
    end

    it '<> fund anywhere' do
      result = { 'score' => 1, 'reason' => 'anywhere' }
      expect(subject.call(@proposal, @anywhere)).to eq result
    end

    it '<> fund local' do
      result = { 'score' => 1, 'reason' => 'exact' }
      expect(subject.call(@proposal, @local)).to eq result
    end

    it '<> fund national' do
      result = { 'score' => 0, 'reason' => 'ineligible' }
      expect(subject.call(@proposal, @national)).to eq result
    end
  end

  context 'proposal intersect' do
    before(:each) do
      @local.geo_area.update! districts: @db[:uk_districts].take(2)
      @proposal.update! districts: @db[:uk_districts].slice(1, 2)
      @proposal.update_column :eligibility, {}
    end

    it '<> fund anywhere' do
      result = { 'score' => 1, 'reason' => 'anywhere' }
      expect(subject.call(@proposal, @anywhere)).to eq result
    end

    it '<> fund local' do
      result = { 'score' => 0, 'reason' => 'intersect' }
      expect(subject.call(@proposal, @local)).to eq result
    end

    it '<> fund national' do
      result = { 'score' => 0, 'reason' => 'ineligible' }
      expect(subject.call(@proposal, @national)).to eq result
    end
  end

  context 'proposal partial' do
    before(:each) do
      @local.geo_area.update!(districts: @db[:uk_districts].take(2))
      @proposal.update! districts: [@db[:uk_districts].first]
      @proposal.update_column :eligibility, {}
    end

    it '<> fund anywhere' do
      result = { 'score' => 1, 'reason' => 'anywhere' }
      expect(subject.call(@proposal, @anywhere)).to eq result
    end

    it '<> fund local' do
      result = { 'score' => 1, 'reason' => 'partial' }
      expect(subject.call(@proposal, @local)).to eq result
    end

    it '<> fund national' do
      result = { 'score' => 0, 'reason' => 'ineligible' }
      expect(subject.call(@proposal, @national)).to eq result
    end
  end

  context 'proposal overlap' do
    before(:each) do
      @proposal.update! districts: @db[:uk_districts]
      @proposal.update_column :eligibility, {}
    end

    it '<> fund anywhere' do
      result = { 'score' => 1, 'reason' => 'anywhere' }
      expect(subject.call(@proposal, @anywhere)).to eq result
    end

    it '<> fund local' do
      result = { 'score' => 0, 'reason' => 'overlap' }
      expect(subject.call(@proposal, @local)).to eq result
    end

    it '<> fund national' do
      result = { 'score' => 0, 'reason' => 'ineligible' }
      expect(subject.call(@proposal, @national)).to eq result
    end
  end
end
