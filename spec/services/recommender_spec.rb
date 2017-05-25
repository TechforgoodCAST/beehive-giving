require 'rails_helper'

describe Recommender do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
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
end
