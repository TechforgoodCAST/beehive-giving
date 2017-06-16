require 'rails_helper'

describe CheckEligibility do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
    @funds = Fund.all
  end

  context 'init' do
    it 'invalid' do
      expect { CheckEligibility.new }.to raise_error(ArgumentError)
    end

    it 'invalid hash of checks' do
      expect { CheckEligibility.new({}) }.to raise_error('Invalid hash of checks')
    end

    it 'valid'
  end
end
