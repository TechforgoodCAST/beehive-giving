require 'rails_helper'
require 'shared/reg_no_validations'
require 'shared/setter_to_integer'

describe User do
  before(:each) do
    @app.create_recipient.with_user
    @db = @app.instances
    @user = @db[:user]
    @recipient = @db[:recipient]
  end

  include_examples 'reg no validations' do
    subject { @user }
  end

  include_examples 'setter to integer' do
    let(:attributes) { [:org_type] }
  end

  it 'belongs to Recipient' do
    expect(@user.organisation).to eq @recipient
    expect(@user.organisation_type).to eq 'Recipient'
  end

  it 'belongs to Funder' do
    funder = create(:funder)
    @user.update(organisation: funder)
    expect(@user.organisation).to eq funder
    expect(@user.organisation_type).to eq 'Funder'
  end

  it 'has many feedbacks' do
    2.times { create(:feedback, user: @user) }
    expect(@user.feedbacks.count).to eq 2
  end

  it 'email is unique' do
    expect(build(:user, email: @user.email))
  end

  it 'a valid user' do
    expect(@user).to be_valid
  end

  it 'invalid name' do
    expect(build(:user, first_name: ':Name!')).not_to be_valid
    expect(build(:user, last_name: ':Name!')).not_to be_valid
  end

  it 'capitalize name and strip whitespace' do
    @user.first_name = ' john '
    @user.save!
    expect(@user.first_name).to eq 'John'
  end

  it 'email is downcased' do
    @user.email = 'UPCASE@email.com'
    @user.save!
    expect(@user.email).to eq 'upcase@email.com'
  end

  it 'org_type converted to integer' do
    @user.org_type = '0'
    @user.save!
    expect(@user.org_type).to eq 0
  end
end
