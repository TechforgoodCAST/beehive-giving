require 'rails_helper'

describe FundInsightCell do
  controller ApplicationController

  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
        .create_recipient.create_registered_proposal
    @fund = Fund.first
    @proposal = Proposal.first
  end

  context '#title' do
    it 'Funder.name as title when funder has one fund' do
      insight = cell(:fund_insight, @fund, proposal: @proposal).call(:title)
      expect(insight).to have_link 'Awards for All 1'
      expect(insight).to have_content 'ACME'

      Fund.last.destroy
      insight = cell(:fund_insight, @fund, proposal: @proposal).call(:title)
      expect(insight).to have_link 'ACME'
      expect(insight).to have_content 'Awards for All 1'
    end
  end
end
