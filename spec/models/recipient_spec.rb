require 'rails_helper'
require_relative '../support/match_helper'

describe Recipient do
  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 2, open_data: true)
        .create_recipient
        .with_user
        .create_complete_proposal
        .create_registered_proposal
    @db = @app.instances
    @recipient = @db[:recipient]
    @proposal = @db[:complete_proposal]
  end

  it 'website invalid' do
    @recipient.website = 'www.example.com'
    expect(@recipient).not_to be_valid
  end

  it 'website valid' do
    @recipient.website = 'https://www.example.com'
    expect(@recipient).to be_valid
  end

  it 'has slug' do
    expect(@recipient.slug).to eq 'acme'
  end

  it 'slug is unique' do
    expect(create(:recipient, name: 'ACME').slug).to eq 'acme-2'
  end

  it 'only updates slug if name present' do
    expect(@recipient.slug).to eq 'acme'

    @recipient.name = ''
    @recipient.save
    expect(@recipient.slug).to eq 'acme'
  end

  it 'updates slug if name changed' do
    expect(@recipient.slug).to eq 'acme'

    @recipient.name = 'New Name!'
    @recipient.save
    expect(@recipient.slug).to eq 'new-name'
  end

  it 'has one subscription' do
    expect(@recipient.subscription).to eq Subscription.first
  end

  it 'has many users' do
    create(:user, organisation: @recipient)
    expect(@recipient.users.count).to eq 2
  end

  it 'has many countries through proposals' do
    @proposal.countries = @db[:countries]
    @proposal.save
    expect(@recipient.countries.count).to eq 2
  end

  it 'has many districts through proposals' do
    expect(@recipient.districts.count).to eq 3
  end

  it 'has one proposal unless subscribed' do
    expect(@recipient.subscribed?).to eq false
    expect(@recipient.proposals.count).to eq 1
  end

  context 'subscribed' do
    before(:each) do
      @app.subscribe_recipient.create_registered_proposal
    end

    it 'has many proposals if subscribed' do
      expect(@recipient.subscribed?).to eq true
      expect(@recipient.proposals.count).to eq 2
    end
  end

  context 'eligibilities' do
    before(:each) do
      2.times do
        create(:recipient_eligibility,
               category: @recipient,
               criterion: create(:restriction, category: 'Recipient'))
      end
    end

    it 'has many eligibilities' do
      expect(@recipient.answers.count).to eq 2
      expect(@recipient.answers.last.category_type).to eq 'Recipient'
    end

    it 'destroys eligibilities' do
      expect(Answer.count).to eq 2
      @recipient.destroy
      expect(Answer.count).to eq 0
    end
  end

  context 'registration numbers present' do
    before(:each) do
      expect(@recipient.charity_number).not_to eq nil
      expect(@recipient.company_number).not_to eq nil
    end

    def clear_numbers(org_type)
      @recipient.org_type = org_type
      @recipient.street_address = 'London Road'
      @recipient.save!
      expect(@recipient.charity_number).to eq nil
      expect(@recipient.company_number).to eq nil
    end

    it 'registration numbers cleared if unregistered' do
      clear_numbers(0)
    end

    it 'registration numbers cleared if other org type' do
      clear_numbers(4)
    end
  end

  it 'requires charity_number if org_type charity' do
    @recipient.org_type = 1
    @recipient.charity_number = nil
    expect(@recipient).not_to be_valid
  end

  it 'requires company_number if org_type company' do
    @recipient.org_type = 2
    @recipient.company_number = nil
    expect(@recipient).not_to be_valid
  end

  it 'requires both numbers if org_type both' do
    @recipient.charity_number = nil
    expect(@recipient).not_to be_valid
    @recipient.charity_number = @recipient.company_number
    @recipient.company_number = nil
    expect(@recipient).not_to be_valid
    @recipient.charity_number = nil
    @recipient.company_number = nil
    expect(@recipient).not_to be_valid
  end

  it 'strips whitespace from charity_number' do
    @recipient.charity_number = ' with whitespace '
    @recipient.save
    expect(@recipient.charity_number).to eq 'with whitespace'
  end

  it 'strips whitespace from company_number' do
    @recipient.company_number = ' with whitespace '
    @recipient.save
    expect(@recipient.company_number).to eq 'with whitespace'
  end

  it 'geocoded by street address and country if no postal code' do
    @recipient.street_address = 'London Road'
    @recipient.save!
    expect(@recipient.postal_code).to be_nil
    expect(@recipient.latitude).to eq 1.0
    expect(@recipient.longitude).to eq 1.0
  end

  it 'only geocode for GB' do
    @recipient.street_address = 'London Road'
    @recipient.country = 'KE'
    @recipient.save!
    expect(@recipient.latitude).to be_nil
    expect(@recipient.longitude).to be_nil
  end

  context 'external request' do
    let(:helper) { MatchHelper.new }

    before(:each) do
      @recipient.update charity_number: '1161998', company_number: '09544506'
      helper.stub_charity_commission.stub_companies_house
    end

    it 'geocoded if postal_code' do
      expect(@recipient.postal_code).to be_nil
      @recipient.scrape_org
      @recipient.save!
      expect(@recipient.postal_code).to eq 'POSTCODE'
      expect(@recipient.latitude).to eq 0.0
      expect(@recipient.longitude).to eq 0.0
    end

    it 'set registered on if scraped' do
      @recipient.operating_for = nil
      @recipient.scrape_org
      expect(@recipient.operating_for).to eq 2
    end
  end

  it 'is valid' do
    expect(@recipient).to be_valid
  end
end
