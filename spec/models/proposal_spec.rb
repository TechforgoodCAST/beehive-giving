require 'rails_helper'

describe Proposal do

  let(:test_helper) { TestHelper.new }

  before(:each) do
    @app = test_helper.
             seed_test_db.
             create_recipient
    @db = @app.instances
  end

  context 'initial' do
    before(:each) do
      @app.build_initial_proposal
      @db = @app.instances
    end

    it 'belongs to Recipient' do
      expect(@db[:initial_proposal].recipient.name).to eq @db[:recipient].name
    end

    it 'valid' do
      expect(@db[:initial_proposal].state).to eq 'initial'
      expect(@db[:initial_proposal]).to be_valid
    end

    it 'invalid' do
      @db[:initial_proposal].funding_duration = -1
      @db[:initial_proposal].save
      expect(@db[:initial_proposal]).not_to be_valid
    end

    it 'defaults to initial state' do
      expect(@db[:initial_proposal].state).to eq 'initial'
    end

    it 'transitions to registered state' do
      @db[:initial_proposal].save
      @db[:initial_proposal].next_step!
      expect(@db[:initial_proposal].state).to eq 'registered'
    end

    it 'generates recommendations when saved' do
      @app.setup_funds
      @db[:initial_proposal].save
      expect(@db[:initial_proposal].recommendations.count).to eq 1
    end

    it 'beneficiaries_other present if beneficiaries_other_required' do
      @db[:initial_proposal].beneficiaries_other_required = true
      expect(@db[:initial_proposal]).not_to be_valid
    end

    it 'must affect_people or affect_other' do
      @db[:initial_proposal].affect_people = false
      expect(@db[:initial_proposal]).not_to be_valid
      @db[:initial_proposal].affect_other = true
      @db[:initial_proposal].beneficiaries = @db[:beneficiaries_other]
      expect(@db[:initial_proposal]).to be_valid
    end

    it 'requires gender if affect_people' do
      @db[:initial_proposal].gender = nil
      expect(@db[:initial_proposal]).to_not be_valid
    end

    it 'requires age_groups if affect_people' do
      @db[:initial_proposal].age_groups = []
      expect(@db[:initial_proposal]).to_not be_valid
    end

    it 'requires beneficiaries if affect_people' do
      @db[:initial_proposal].beneficiaries = []
      expect(@db[:initial_proposal]).to_not be_valid
    end

    it 'does not require gender and age_groups if affect_other' do
      @db[:initial_proposal].affect_people = false
      @db[:initial_proposal].affect_other = true
      @db[:initial_proposal].gender = nil
      @db[:initial_proposal].age_groups = []
      expect(@db[:initial_proposal]).to be_valid
    end

    it 'required beneficiaries from category "Other" if affect_other' do
      @db[:initial_proposal].affect_people = false
      @db[:initial_proposal].affect_other = true
      expect(@db[:initial_proposal]).to be_valid
      expect(@db[:initial_proposal].beneficiaries).to eq @db[:beneficiaries_other]
    end

    it 'selects all ages groups is "All ages" selected' do
      @db[:initial_proposal].age_groups = [@db[:all_ages]]
      @db[:initial_proposal].save
      expect(@db[:initial_proposal].age_groups).to eq @db[:age_groups]
    end

    it 'clears beneficiaries from category "People" unless affect_people' do
      expect(@db[:initial_proposal].beneficiaries).to eq @db[:beneficiaries]
      @db[:initial_proposal].affect_people = false
      @db[:initial_proposal].affect_other = true
      @db[:initial_proposal].save
      expect(@db[:initial_proposal].beneficiaries).to eq @db[:beneficiaries_other]
    end

    it 'clears beneficiaries from category "Other" unless affect_other' do
      expect(@db[:initial_proposal].beneficiaries).to eq @db[:beneficiaries]
      @db[:initial_proposal].save
      expect(@db[:initial_proposal].beneficiaries).to eq @db[:beneficiaries_people]
    end

    it 'does not clear beneficiaries if both affect_people and affect_other' do
      @db[:initial_proposal].affect_other = true
      @db[:initial_proposal].save
      expect(@db[:initial_proposal].beneficiaries).to eq @db[:beneficiaries]
    end

    it 'does not require districts if affect_geo at country level' do
      Proposal::AFFECT_GEO.each do |i|
        @db[:initial_proposal].affect_geo = i[1]
        @db[:initial_proposal].districts = []
        if i[1] < 2
          expect(@db[:initial_proposal]).not_to be_valid
        else
          expect(@db[:initial_proposal]).to be_valid
        end
      end
    end

    it 'populates districts by country selection if at country level' do
      @db[:initial_proposal].affect_geo = 2
      @db[:initial_proposal].countries = [@db[:kenya]]
      @db[:initial_proposal].districts = []
      @db[:initial_proposal].save
      expect(@db[:initial_proposal].districts).to eq @db[:kenya].districts
    end

    it 'sets affect_geo unless affects entire country'
  end

  context 'registered' do
    before(:each) do
      @app.build_registered_proposal
      @db = @app.instances
    end

    it 'valid' do
      expect(@db[:registered_proposal].state).to eq 'registered'
      expect(@db[:registered_proposal]).to be_valid
    end

    it 'invalid' do
      @db[:registered_proposal].title = nil
      @db[:registered_proposal].funding_duration = nil
      expect(@db[:registered_proposal]).not_to be_valid
    end

    it 'transitions to complete' do
      @db[:registered_proposal].save
      @db[:registered_proposal].next_step!
      expect(@db[:registered_proposal].state).to eq 'complete'
    end

    it 'cannot create second proposal until first proposal complete' do
      @db[:registered_proposal].save
      @app.build_initial_proposal
      @db = @app.instances
      expect(@db[:initial_proposal]).not_to be_valid
    end
  end

  context 'complete' do
    before(:each) do
      @app.build_complete_proposal
      @db = @app.instances
    end

    it 'valid' do
      expect(@db[:complete_proposal].state).to eq 'complete'
      expect(@db[:complete_proposal]).to be_valid
    end

    it 'invalid' do
      @db[:complete_proposal].title = nil
      @db[:complete_proposal].funding_duration = nil
      expect(@db[:complete_proposal]).not_to be_valid
    end

    context 'with second proposal' do
      before(:each) do
        @app.build_registered_proposal
        @db = @app.instances
      end

      it 'can create multiple proposals once first proposal complete' do
        @db[:complete_proposal].save
        @db[:registered_proposal].save
        expect(@db[:recipient].proposals.count).to eq 2
      end

      it 'cannot have duplicate titles' do
        @db[:complete_proposal].save
        @db[:registered_proposal].title = @db[:complete_proposal].title
        expect(@db[:registered_proposal]).not_to be_valid
      end
    end
  end
end
