require 'rails_helper'

describe Implementation do
  before(:each) do
    @app.seed_test_db
    @db = @app.instances
  end

  it 'is valid' do
    8.times do |i|
      expect(@db[:implementations][i][:label]).to eq Implementation::IMPLEMENTATIONS[i][:label]
    end
  end

  it 'has 8 records' do
    expect(Implementation.all.count).to eq 8
  end
end
