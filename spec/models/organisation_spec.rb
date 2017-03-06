require 'rails_helper'
require_relative '../support/match_helper'

describe Organisation do
  let(:helper) { MatchHelper.new }

  before(:each) do
    helper.stub_charity_commission.stub_companies_house
    @app.seed_test_db
        .create_recipient(charity_number: '1161998', company_number: '09544506')
        .with_user
    @db = @app.instances
    @org = @db[:recipient]
  end

  it 'has slug' do
    expect(@org.slug).to eq 'acme'
  end

  it 'slug is unique' do
    expect(create(:recipient, name: 'ACME').slug).to eq 'acme-2'
  end

  it 'has one subscription' do
    expect(@org.subscription).to eq Subscription.first
  end

  it 'has many users' do
    create(:user, organisation: @org)
    expect(@org.users.count).to eq 2
  end

  it 'is valid' do
    expect(@org).to be_valid
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

  it 'geocoded if postal_code' do
    expect(@org.postal_code).to be_nil
    @org.scrape_org
    @org.save!
    expect(@org.postal_code).to eq 'POSTCODE'
    expect(@org.latitude).to eq 0.0
    expect(@org.longitude).to eq 0.0
  end

  it 'geocoded by street address and country if no postal code' do
    @org.street_address = 'London Road'
    @org.save!
    expect(@org.postal_code).to be_nil
    expect(@org.latitude).to eq 1.0
    expect(@org.longitude).to eq 1.0
  end

  it 'only geocode for GB' do
    @org.street_address = 'London Road'
    @org.country = 'KE'
    @org.save!
    expect(@org.latitude).to be_nil
    expect(@org.longitude).to be_nil
  end

  it 'set registered on if scraped' do
    @org.operating_for = nil
    @org.scrape_org
    expect(@org.operating_for).to eq 2
  end
end
