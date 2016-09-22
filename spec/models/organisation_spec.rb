require 'rails_helper'

describe Organisation do

  before(:each) do
    @app.seed_test_db.create_recipient.with_user
    @db = @app.instances
    @org = @db[:recipient]
  end

  it 'has one subscription' do
    expect(@org.subscription).to eq Subscription.first
  end

  it 'has many users' do
    create(:user, organisation: @org)
    expect(@org.users.count).to eq 2
  end

  context 'registration numbers present' do
    before(:each) do
      expect(@org.charity_number).not_to eq nil
      expect(@org.company_number).not_to eq nil
    end

    def clear_numbers(org_type)
      @org.org_type = org_type
      @org.street_address = 'London Road'
      @org.save!
      expect(@org.charity_number).to eq nil
      expect(@org.company_number).to eq nil
    end

    it 'registration numbers cleared if unregistered' do
      clear_numbers(0)
    end

    it 'registration numbers cleared if other org type' do
      clear_numbers(4)
    end
  end

  it 'requires charity_number if org_type charity' do
    @org.org_type = 1
    @org.charity_number = nil
    expect(@org).not_to be_valid
  end

  it 'requires company_number if org_type company' do
    @org.org_type = 2
    @org.company_number = nil
    expect(@org).not_to be_valid
  end

  it 'requires both numbers if org_type both' do
    @org.charity_number = nil
    expect(@org).not_to be_valid
    @org.charity_number = @org.company_number
    @org.company_number = nil
    expect(@org).not_to be_valid
    @org.charity_number = nil
    @org.company_number = nil
    expect(@org).not_to be_valid
  end

end
