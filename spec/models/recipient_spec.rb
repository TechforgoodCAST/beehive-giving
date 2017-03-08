require 'rails_helper'

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

  it 'only updates slug if name present' do
    expect(@recipient.slug).to eq 'acme-2'

    @recipient.name = ''
    @recipient.save
    expect(@recipient.slug).to eq 'acme-2'
  end

  it 'updates slug if name changed' do
    expect(@recipient.slug).to eq 'acme-2'

    @recipient.name = 'New Name!'
    @recipient.save
    expect(@recipient.slug).to eq 'new-name-'
  end

  it 'has many funds through proposals' do
    expect(@recipient.funds.count).to eq 2
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
               restriction: create(:restriction, category: 'Organisation'))
      end
    end

    it 'has many eligibilities' do
      expect(@recipient.eligibilities.count).to eq 2
      expect(@recipient.eligibilities.last.category_type).to eq 'Organisation'
    end

    it 'destroys eligibilities' do
      expect(Eligibility.count).to eq 2
      @recipient.destroy
      expect(Eligibility.count).to eq 0
    end
  end
end
