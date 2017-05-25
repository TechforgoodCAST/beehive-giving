require 'rails_helper'

describe FundCardCell do
  controller ApplicationController

  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @fund = Fund.last
    @proposal = Proposal.last
  end

  context '#location' do
    it 'shows ineligible' do
      @proposal.update_column :eligibility, @fund.slug => { 'location' => false }
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_link 'Ineligible'
    end

    it 'shows recommendation' do
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Fair'
    end
  end
end
