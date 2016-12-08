require 'rails_helper'

describe Feedback do
  before(:each) do
    @app.seed_test_db.with_user
    @db = @app.instances
    @feedback = create(:feedback, user: @db[:user])
  end

  it 'belongs to user' do
    expect(@feedback.user).to eq @db[:user]
  end

  it 'is valid' do
    expect(Feedback.count).to eq 1
    expect(@feedback.valid?)
  end

  it 'price required on update' do
    expect { @feedback.save! }.to raise_error(ActiveRecord::RecordInvalid)
    @feedback.price = 50
    @feedback.save!
    expect(@feedback).to be_valid
  end
end
