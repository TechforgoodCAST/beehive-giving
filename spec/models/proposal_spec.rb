require 'rails_helper'

describe Proposal do
  before(:each) do
    @app.seed_test_db
        .create_recipient
    @db = @app.instances
  end

  context 'initial' do
    before(:each) do
      @app.build_initial_proposal
      @db = @app.instances
      @initial_proposal = @db[:initial_proposal]
    end

    it 'belongs to Recipient' do
      expect(@initial_proposal.recipient.name).to eq @db[:recipient].name
    end

    context 'saved' do
      before(:each) do
        @initial_proposal.save
      end

      it 'has many age_groups' do
        expect(@initial_proposal.age_groups.count).to eq 8
      end

      it 'has many beneficiaries' do
        expect(@initial_proposal.beneficiaries.count).to eq 20
      end

      it 'has many countries' do
        @initial_proposal.countries = @db[:countries]
        @initial_proposal.districts = @db[:districts]
        @initial_proposal.save
        expect(@initial_proposal.countries.count).to eq 2
      end

      it 'has many districts' do
        expect(@initial_proposal.districts.count).to eq 3
      end
    end

    context 'with funds' do
      before(:each) do
        @app.setup_funds(num: 2, open_data: true)
        @initial_proposal.save
      end

      it 'has many recommendations and generates recommendations when saved' do
        expect(@initial_proposal.recommendations.count).to eq 2
      end

      it 'has many funds through recommendations' do
        expect(@initial_proposal.funds.count).to eq 2
      end
    end

    it 'valid' do
      expect(@initial_proposal.state).to eq 'initial'
      expect(@initial_proposal).to be_valid
    end

    it 'invalid' do
      @initial_proposal.funding_duration = -1
      @initial_proposal.save
      expect(@initial_proposal).not_to be_valid
    end

    it 'defaults to initial state' do
      expect(@initial_proposal.state).to eq 'initial'
    end

    it 'transitions to registered state' do
      @initial_proposal.save
      @initial_proposal.next_step!
      expect(@initial_proposal.state).to eq 'registered'
    end

    it 'beneficiaries_other present if beneficiaries_other_required' do
      @initial_proposal.beneficiaries_other_required = true
      expect(@initial_proposal).not_to be_valid
    end

    it 'must affect_people or affect_other' do
      @initial_proposal.affect_people = false
      expect(@initial_proposal).not_to be_valid
      @initial_proposal.affect_other = true
      @initial_proposal.beneficiaries = @db[:beneficiaries_other]
      expect(@initial_proposal).to be_valid
    end

    it 'requires gender if affect_people' do
      @initial_proposal.gender = nil
      expect(@initial_proposal).to_not be_valid
    end

    it 'requires age_groups if affect_people' do
      @initial_proposal.age_groups = []
      expect(@initial_proposal).to_not be_valid
    end

    it 'requires beneficiaries if affect_people' do
      @initial_proposal.beneficiaries = []
      expect(@initial_proposal).to_not be_valid
    end

    it 'does not require gender and age_groups if affect_other' do
      @initial_proposal.affect_people = false
      @initial_proposal.affect_other = true
      @initial_proposal.gender = nil
      @initial_proposal.age_groups = []
      expect(@initial_proposal).to be_valid
    end

    it 'required beneficiaries from category "Other" if affect_other' do
      @initial_proposal.affect_people = false
      @initial_proposal.affect_other = true
      expect(@initial_proposal).to be_valid
      expect(@initial_proposal.beneficiaries).to eq @db[:beneficiaries_other]
    end

    it 'selects all ages groups is "All ages" selected' do
      @initial_proposal.age_groups = [@db[:all_ages]]
      @initial_proposal.save
      expect(@initial_proposal.age_groups).to eq @db[:age_groups]
    end

    it 'clears beneficiaries from category "People" unless affect_people' do
      @app.stub_beneficiaries_endpoint(['Other'])
      expect(@initial_proposal.beneficiaries).to eq @db[:beneficiaries]
      @initial_proposal.affect_people = false
      @initial_proposal.affect_other = true
      @initial_proposal.save
      expect(@initial_proposal.beneficiaries).to eq @db[:beneficiaries_other]
    end

    it 'clears beneficiaries from category "Other" unless affect_other' do
      expect(@initial_proposal.beneficiaries).to eq @db[:beneficiaries]
      @initial_proposal.save
      expect(@initial_proposal.beneficiaries).to eq @db[:beneficiaries_people]
    end

    it 'does not clear beneficiaries if both affect_people and affect_other' do
      @app.stub_beneficiaries_endpoint(['People', 'Other'])
      @initial_proposal.affect_other = true
      @initial_proposal.save
      expect(@initial_proposal.beneficiaries).to eq @db[:beneficiaries]
    end

    it 'does not require districts if affect_geo at country level' do
      Proposal::AFFECT_GEO.each do |i|
        @initial_proposal.affect_geo = i[1]
        @initial_proposal.districts = []
        if i[1] < 2
          expect(@initial_proposal).not_to be_valid
        else
          expect(@initial_proposal).to be_valid
        end
      end
    end

    it 'populates districts by country selection if at country level' do
      @initial_proposal.affect_geo = 2
      @initial_proposal.countries = [@db[:kenya]]
      @initial_proposal.districts = []
      @initial_proposal.save
      expect(@initial_proposal.districts).to eq @db[:kenya].districts
    end

    it 'sets affect_geo unless affects entire country'
  end

  context 'registered' do
    before(:each) do
      @app.build_registered_proposal
      @db = @app.instances
      @registered_proposal = @db[:registered_proposal]
    end

    it 'has many implementations' do
      @registered_proposal.save
      expect(@registered_proposal.implementations.count).to eq 8
    end

    it 'valid' do
      expect(@registered_proposal.state).to eq 'registered'
      expect(@registered_proposal).to be_valid
    end

    it 'invalid' do
      @registered_proposal.title = nil
      @registered_proposal.funding_duration = nil
      expect(@registered_proposal).not_to be_valid
    end

    it 'transitions to complete' do
      @registered_proposal.save
      @registered_proposal.next_step!
      expect(@registered_proposal.state).to eq 'complete'
    end

    it 'cannot create second proposal until first proposal complete' do
      @registered_proposal.save
      @app.build_initial_proposal
      @db = @app.instances
      expect(@db[:initial_proposal]).not_to be_valid
    end
  end

  context 'complete' do
    before(:each) do
      @app.build_complete_proposal
      @db = @app.instances
      @complete_proposal = @db[:complete_proposal]
    end

    it 'valid' do
      expect(@complete_proposal.state).to eq 'complete'
      expect(@complete_proposal).to be_valid
    end

    it 'invalid' do
      @complete_proposal.title = nil
      @complete_proposal.funding_duration = nil
      expect(@complete_proposal).not_to be_valid
    end

    context 'with second proposal' do
      before(:each) do
        @app.build_registered_proposal
        @db = @app.instances
        @registered_proposal = @db[:registered_proposal]
        @complete_proposal   = @db[:complete_proposal]
      end

      it 'can create multiple proposals once first proposal complete' do
        @complete_proposal.save
        @registered_proposal.save
        expect(@db[:recipient].proposals.count).to eq 2
      end

      it 'cannot have duplicate titles' do
        @complete_proposal.save
        @registered_proposal.title = @complete_proposal.title
        expect(@registered_proposal).not_to be_valid
      end
    end
  end
end
