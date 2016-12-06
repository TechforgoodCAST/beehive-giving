require 'rails_helper'

describe AgeGroup do
  before(:each) do
    @app.seed_test_db
    @db = @app.instances
  end

  it 'is valid' do
    8.times do |i|
      %w(label age_from age_to).each do |field|
        expect(@db[:age_groups][i][field]).to eq AgeGroup::AGE_GROUPS[i][field.to_sym]
      end
    end
  end

  it 'has 8 records' do
    expect(AgeGroup.all.count).to eq 8
  end
end
