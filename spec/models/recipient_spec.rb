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

  it 'has many proposals' do
    expect(@recipient.proposals.count).to eq 2
  end

  it 'has many funds through proposals' do
    expect(@recipient.funds.count).to eq 2
  end

  it 'has many countries through proposals' do
    @proposal.countries = @db[:countries]
    @proposal.save!
    expect(@recipient.countries.count).to eq 2
  end

  it 'has many districts through proposals' do
    expect(@recipient.districts.count).to eq 3
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

    # TODO: remove
    # it 'has many restrictions through eligibilities' do
    #   expect(@recipient.restrictions.count).to eq 2
    #   expect(@recipient.restrictions.pluck(:category).uniq)
    #     .to eq ['Organisation']
    # end

    it 'destroys eligibilities' do
      expect(Eligibility.count).to eq 2
      @recipient.destroy
      expect(Eligibility.count).to eq 0
    end
  end

  it 'unlocked_funds'
  it 'eligible_funds'
  it 'ineligible_funds'
  it 'unlocked_fund?'
  it 'locked_fund?'
  it 'recommended_with_eligible_funds'
end
