require 'rails_helper'

describe FundIndicatorsCell do
  controller ApplicationController

  before(:each) do
    @app.seed_test_db.setup_funds(open_data: true)
        .create_recipient.create_registered_proposal
    @db = @app.instances
    @fund = Fund.first
    @proposal = Proposal.first
    @path = proposal_fund_path(@proposal, @fund, anchor: 'eligibility')
  end

  context 'eligibility' do
    it 'check' do
      indicator = cell(:fund_indicators, @fund, proposal: @proposal).call(:show)
      expect(indicator).to have_link 'Check eligibility', href: @path
      expect(indicator).to have_css '.bg-blue'
    end

    it 'ineligible' do
      @proposal.update_column(
        :eligibility, @fund.slug => { 'location' => { 'eligible' => false } }
      )
      indicator = cell(:fund_indicators, @fund, proposal: @proposal).call(:show)
      expect(indicator).to have_link 'Ineligible', href: @path
      expect(indicator).to have_css '.bg-red'
    end

    it 'eligible' do
      @proposal.update_column(
        :eligibility, @fund.slug => { 'quiz' => { 'eligible' => true } }
      )
      indicator = cell(:fund_indicators, @fund, proposal: @proposal).call(:show)
      expect(indicator).to have_link 'Eligible', href: @path
      expect(indicator).to have_css '.bg-green'
    end
  end
end
