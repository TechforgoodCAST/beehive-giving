require 'rails_helper'

describe LocationMatch do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
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

    context '#match' do
      it 'ineligble set to -1' do
        @proposal.eligibility = {
          @local.slug => { 'quiz' => true },
          @anywhere.slug => { 'location' => false }
        }
        match = LocationMatch.new(@funds, @proposal).match
        result = { 'location' => { 'score' => -1, 'reason' => 'ineligible' } }
        expect(match[@anywhere.slug]).to eq result
      end

      context 'proposal national' do
        before(:each) do
          @proposal.update! affect_geo: 2, district_ids: []
          @proposal.update_column :eligibility, {}
          @match = LocationMatch.new(@funds, @proposal).match
        end

        it '<> fund anywhere' do
          result = { 'location' => { 'score' => 1, 'reason' => 'anywhere' } }
          expect(@proposal.recommendation[@anywhere.slug]).to eq result
        end

        it '<> fund local' do
          result = { 'location' => { 'score' => -1, 'reason' => 'overlap' } }
          expect(@match[@local.slug]).to eq result
          expect(@proposal.recommendation[@local.slug]).to eq result
        end

        it '<> fund national' do
          result = { 'location' => { 'score' => 1, 'reason' => 'national' } }
          expect(@proposal.recommendation[@national.slug]).to eq result
        end
      end

      context 'proposal exact' do
        before(:each) do
          @proposal.update! districts: [@db[:uk_districts].first]
        end

        it '<> fund anywhere' do
          result = { 'location' => { 'score' => 1, 'reason' => 'anywhere' } }
          expect(@proposal.recommendation[@anywhere.slug]).to eq result
        end

        it '<> fund local' do
          result = { 'location' => { 'score' => 1, 'reason' => 'exact' } }
          expect(@proposal.recommendation[@local.slug]).to eq result
        end

        it '<> fund national' do
          result = { 'location' => { 'score' => -1, 'reason' => 'ineligible' } }
          expect(@proposal.recommendation[@national.slug]).to eq result
        end
      end

      context 'proposal intersect' do
        before(:each) do
          @local.update! districts: @db[:uk_districts].take(2)
          @proposal.update! districts: @db[:uk_districts].slice(1, 2)
        end

        it '<> fund anywhere' do
          result = { 'location' => { 'score' => 1, 'reason' => 'anywhere' } }
          expect(@proposal.recommendation[@anywhere.slug]).to eq result
        end

        it '<> fund local' do
          result = { 'location' => { 'score' => 0, 'reason' => 'intersect' } }
          expect(@proposal.recommendation[@local.slug]).to eq result
        end

        it '<> fund national' do
          result = { 'location' => { 'score' => -1, 'reason' => 'ineligible' } }
          expect(@proposal.recommendation[@national.slug]).to eq result
        end
      end

      context 'proposal partial' do
        before(:each) do
          @local.update! districts: @db[:uk_districts].take(2)
          @proposal.update! districts: [@db[:uk_districts].first]
        end

        it '<> fund anywhere' do
          result = { 'location' => { 'score' => 1, 'reason' => 'anywhere' } }
          expect(@proposal.recommendation[@anywhere.slug]).to eq result
        end

        it '<> fund local' do
          result = { 'location' => { 'score' => 1, 'reason' => 'partial' } }
          expect(@proposal.recommendation[@local.slug]).to eq result
        end

        it '<> fund national' do
          result = { 'location' => { 'score' => -1, 'reason' => 'ineligible' } }
          expect(@proposal.recommendation[@national.slug]).to eq result
        end
      end

      context 'proposal overlap' do
        before(:each) do
          @proposal.update! districts: @db[:uk_districts]
        end

        it '<> fund anywhere' do
          result = { 'location' => { 'score' => 1, 'reason' => 'anywhere' } }
          expect(@proposal.recommendation[@anywhere.slug]).to eq result
        end

        it '<> fund local' do
          result = { 'location' => { 'score' => -1, 'reason' => 'overlap' } }
          expect(@proposal.recommendation[@local.slug]).to eq result
        end

        it '<> fund national' do
          result = { 'location' => { 'score' => -1, 'reason' => 'ineligible' } }
          expect(@proposal.recommendation[@national.slug]).to eq result
        end
      end
    end
  end
end
