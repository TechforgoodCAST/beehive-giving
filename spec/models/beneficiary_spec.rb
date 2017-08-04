require 'rails_helper'

describe Beneficiary do
  before(:each) do
    @app.seed_test_db
    @db = @app.instances
  end

  it 'has 25 records' do
    expect(Beneficiary.all.count).to eq 25
  end
end
