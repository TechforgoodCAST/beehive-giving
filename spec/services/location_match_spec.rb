require 'rails_helper'

describe LocationMatch do
  context 'init' do
    before(:each) do
      @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
      @funds = Fund.active.all
      @proposal = Proposal.last
    end

    it 'requires funds and proposal to initialize' do
      expect { LocationMatch.new }.to raise_error(ArgumentError)
      expect { LocationMatch.new(@funds) }.to raise_error(ArgumentError)
      expect { LocationMatch.new(@funds, @proposal) }.not_to raise_error
    end

    it 'invalid funds collection raises errror' do
      expect { LocationMatch.new({}, @proposal) }
        .to raise_error('Invalid Fund::ActiveRecord_Relation')
    end

    it 'empty funds collection raises errror' do
      Fund.destroy_all
      expect { LocationMatch.new(@funds, @proposal) }
        .to raise_error('No funds supplied')
    end

    it 'invalid proposal object raises error' do
      expect { LocationMatch.new(@funds, {}) }
        .to raise_error('Invalid Proposal object')
    end
  end

  context 'fund seeking work in other countries' do
    before(:each) do
      @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
      @funds = Fund.active.all
      @proposal = Proposal.last
    end

    it 'Fund eligible for Proposal that matches Fund.countries' do
      result = {
        @funds.first.slug => { eligible: true, reason: 'location' }
      }

      expect(LocationMatch.new(@funds, @proposal).match).to eq result
    end

    it 'Fund ineligible for Proposal that does not match Fund.countries' do
      @funds.first.country_ids = [Country.last.id]
      @funds.first.save!

      result = {
        @funds.first.slug => { eligible: false, reason: 'location' }
      }

      expect(LocationMatch.new(@funds, @proposal).match).to eq result
    end
  end

  context 'fund seeking work at national scale' do
    it 'fund eligible for proposal seeking funding at national level'
    it 'fund ineligible for proposal seeking funding at national level'
  end

  context 'fund seeking work at a local level' do
    it 'fund neutral with notice for national proposal'
    it 'fund ineligible with notice for local proposal no district match'
    it 'fund eligible with notice for local proposal partial/full match'
    it 'fund neutral with notice for local proposal intersect/overlap match'
  end

  context 'fund seeking work at any level' do
    it 'fund eligible with notice for local proposal'
    it 'fund eligible with notice for national proposal'
  end
end
