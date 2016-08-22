require 'rails_helper'

describe Beneficiary do
  before(:each) do
    @app.seed_test_db
    @db = @app.instances
  end

  it 'is valid' do
    24.times do |i|
      %w[label category sort].each do |field|
        expect(@db[:beneficiaries][i][field]).to eq Beneficiary::BENEFICIARIES[i][field.to_sym]
      end
    end
  end

  it 'has 25 records' do
    expect(Beneficiary.all.count).to eq 25
  end
end
