require 'rails_helper'

describe Proposal do
  before(:each) do
    @app.seed_test_db
        .create_recipient
    @db = @app.instances
  end

  it 'eligibility field'

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

      it 'has many proposal_themes' do
        expect(@initial_proposal.proposal_themes.count).to eq 3
      end

      it 'has many themes' do
        expect(@initial_proposal.themes.count).to eq 3
      end

      it 'has at least one theme' do
        @initial_proposal.themes = []
        expect(@initial_proposal).not_to be_valid
      end

      it 'has many age_groups' do
        expect(@initial_proposal.age_groups.count).to eq 8
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
        @app.setup_funds(open_data: true)
        @initial_proposal.save
      end

      it '#update_legacy_suitability' do
        result = {
          'funder-awards-for-all-1' => {
            'amount'   => { 'score' => 0.2 },
            'duration' => { 'score' => 0.1 },
            'location' => { 'score' => 1, 'reason' => 'anywhere' },
            'org_type' => { 'score' => 0.41500000000000004 },
            'theme'    => { 'score' => 1.0 },
            'total'    => 0.0
          }
        }

        @initial_proposal.suitability = {}
        @initial_proposal.update_legacy_suitability
        expect(@initial_proposal.suitability).to eq result

        @initial_proposal.suitability = { 'key' => 'value' }
        @initial_proposal.update_legacy_suitability
        expect(@initial_proposal.suitability).to eq result
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

    it 'clears age_groups and gender unless affect_people' do
      expect(@initial_proposal.age_groups.size).to eq 8
      expect(@initial_proposal.gender).to eq 'Female'

      @initial_proposal.affect_people = false
      @initial_proposal.save!

      expect(@initial_proposal.age_groups.size).to eq 0
      expect(@initial_proposal.gender).to eq nil
    end

    it 'requires gender if affect_people' do
      @initial_proposal.gender = nil
      expect(@initial_proposal).to_not be_valid
    end

    it 'requires age_groups if affect_people' do
      @initial_proposal.age_groups = []
      expect(@initial_proposal).to_not be_valid
    end

    it 'does not require gender and age_groups if affect_other' do
      @initial_proposal.affect_people = false
      @initial_proposal.affect_other = true
      @initial_proposal.gender = nil
      @initial_proposal.age_groups = []
      expect(@initial_proposal).to be_valid
    end

    it 'selects all ages groups is "All ages" selected' do
      @initial_proposal.age_groups = [@db[:all_ages]]
      @initial_proposal.save
      expect(@initial_proposal.age_groups).to eq @db[:age_groups]
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

    it '#clear_districts_if_country_wide' do
      expect(@initial_proposal.district_ids.count).to eq 3
      expect(@initial_proposal.affect_geo).to eq 1
      @initial_proposal.affect_geo = 2
      @initial_proposal.save
      expect(@initial_proposal.district_ids.count).to eq 0
    end
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
  end

  context 'eligibilities' do
    before(:each) do
      @app.create_registered_proposal
      @proposal = @app.instances[:registered_proposal]
      2.times do
        create(:proposal_eligibility,
               category: @proposal,
               restriction: create(:restriction))
      end
    end

    it 'has many eligibilities' do
      expect(@proposal.eligibilities.count).to eq 2
      expect(@proposal.eligibilities.last.category_type)
        .to eq 'Proposal'
    end

    it 'destroys eligibilities' do
      expect(Eligibility.count).to eq 2
      @proposal.destroy
      expect(Eligibility.count).to eq 0
    end
  end

  context 'multiple' do
    before(:each) do
      @app.create_complete_proposal.build_registered_proposal
      @proposal = @app.instances[:complete_proposal]
      @proposal2 = @app.instances[:registered_proposal]
    end

    it 'cannot have duplicate titles' do
      @proposal2.title = @proposal.title
      expect(@proposal2).not_to be_valid
    end

    it 'can create multiple proposals once first proposal complete ' \
       'and subscribed' do
      @app.subscribe_recipient
      @proposal2.save!
      expect(@app.instances[:recipient].proposals.count).to eq 2
    end

    it 'cannot create multiple proposals unless subscribed' do
      expect(@proposal2.recipient.subscribed?).to eq false
      expect { @proposal2.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'can create multiple proposals if subscribed' do
      @proposal2.recipient.subscribe!
      expect(@proposal2.recipient.subscribed?).to eq true
      expect(@proposal2).to be_valid
    end
  end

  context 'methods' do
    before(:each) do
      eligibility = {
        'fund1' => { 'quiz' => { 'eligible' => false } },
        'fund2' => { 'quiz' => { 'eligible' => true }, 'other' => { 'eligible' => true } },
        'fund3' => { 'quiz' => { 'eligible' => true }, 'other' => { 'eligible' => false } },
        'fund4' => { 'other' => { 'eligible' => false } },
        'fund5' => { 'other' => { 'eligible' => true } }
      }
      @proposal = Proposal.new(eligibility: eligibility)
    end

    it '#show_fund?'

    it '#checked_fund?'

    it '#eligible_funds' do

      expect(@proposal.eligible_funds).to eq 'fund2' => { 'quiz' => { 'eligible' => true }, 'other' => { 'eligible' => true } }
    end

    it '#ineligible_funds' do
      expect(@proposal.ineligible_funds).to eq 'fund1' => {"quiz"=>{"eligible"=>false}}, 'fund3' => {"quiz"=>{"eligible"=>true}, "other"=>{"eligible"=>false}}, 'fund4' => {"other"=>{"eligible"=>false}}
    end

    it '#eligible? unchecked' do
      expect(@proposal.eligible?('fund4')).to eq nil
    end

    it '#eligible? eligible' do
      expect(@proposal.eligible?('fund2')).to eq true
    end

    it '#eligible? ineligible' do
      expect(@proposal.eligible?('fund1')).to eq false
      expect(@proposal.eligible?('fund3')).to eq false
    end

    it '#eligible_status unchecked' do
      expect(@proposal.eligible_status('fund5')).to eq(-1)
    end

    it '#eligible_status eligible' do
      expect(@proposal.eligible_status('fund2')).to eq 1
    end

    it '#eligible_status ineligible' do
      expect(@proposal.eligible_status('fund1')).to eq 0
      expect(@proposal.eligible_status('fund3')).to eq 0
      expect(@proposal.eligible_status('fund4')).to eq 0
    end

    it '#eligibility_as_text check' do
      expect(@proposal.eligibility_as_text('fund5')).to eq 'Check'
    end

    it '#eligibility_as_text eligible' do
      expect(@proposal.eligibility_as_text('fund2')).to eq 'Eligible'
    end

    it '#eligibility_as_text ineligible' do
      expect(@proposal.eligibility_as_text('fund1')).to eq 'Ineligible'
      expect(@proposal.eligibility_as_text('fund3')).to eq 'Ineligible'
      expect(@proposal.eligibility_as_text('fund4')).to eq 'Ineligible'
    end
  end
end
