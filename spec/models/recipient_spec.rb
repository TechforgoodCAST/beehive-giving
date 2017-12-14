require 'rails_helper'
require 'support/match_helper'
require 'shared/recipient_validations'
require 'shared/reg_no_validations'
require 'shared/org_type_validations'

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

  include_examples 'recipient validations' do
    subject { @recipient }
  end

  include_examples 'reg no validations' do
    subject { @recipient }
  end

  include_examples 'org_type validations' do
    subject { @recipient }
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

  it 'has many Attempts' do
    expect(Recipient.reflect_on_association(:attempts).macro).to eq :has_many
  end

  it 'has many countries through proposals' do
    @proposal.countries = @db[:countries]
    @proposal.save
    expect(@recipient.countries.count).to eq 2
  end

  it 'has many districts through proposals' do
    expect(@recipient.districts.count).to eq 3
  end

  it 'reveals only has unique fund slugs' do
    @recipient.reveals = %w[fund-slug-1 fund-slug-1]
    @recipient.save
    expect(@recipient.reveals).to eq ['fund-slug-1']
  end

  it 'reveals push only has unique fund slugs' do
    @recipient.reveals << 'fund-slug-1'
    @recipient.reveals << 'fund-slug-1'
    @recipient.save
    expect(@recipient.reveals).to eq ['fund-slug-1']
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

  it 'blank registration numbers are nil' do
    %i[charity_number company_number].each do |attribute|
      @recipient.send("#{attribute}=", '')
      expect(@recipient[attribute]).to eq nil
    end
  end

  it 'registration numbers strip whitespace' do
    %i[charity_number company_number].each do |attribute|
      @recipient.send("#{attribute}=", ' strip whitespace ')
      expect(@recipient[attribute]).to eq 'strip whitespace'
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
