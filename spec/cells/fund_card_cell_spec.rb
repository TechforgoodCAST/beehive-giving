require 'rails_helper'

describe FundCardCell do
  controller ApplicationController

  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @db = @app.instances
    @fund = Fund.last
    @proposal = Proposal.last
  end

  context '#location' do
    it 'ineligible message' do
      @proposal.update_column :eligibility, @fund.slug => { 'location' => false }
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Does not fund the areas in your proposal.'
      expect(card).to have_link 'Ineligible'
    end

    it 'anywhere message' do
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Accepts proposals from anywhere in the country.'
      expect(card).to have_content 'Good'
    end

    it 'exact message' do
      @fund.update!(
        geographic_scale_limited: true,
        countries: @proposal.countries,
        districts: @proposal.districts
      )
      @proposal.save!
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports all of the areas in your proposal.'
      expect(card).to have_content 'Good'
    end

    it 'intersect message' do
      @fund.update!(
        geographic_scale_limited: true,
        countries: @proposal.countries,
        districts: @db[:uk_districts].take(2)
      )
      @proposal.update! districts: @db[:uk_districts].slice(1, 2)
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports some of the areas in your proposal.'
      expect(card).to have_content 'Neutral'
    end

    it 'partial message' do
      @fund.update!(
        geographic_scale_limited: true,
        countries: @proposal.countries,
        districts: @db[:uk_districts].take(2)
      )
      @proposal.update! districts: [@db[:uk_districts].first]
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports all of the areas in your proposal.'
      expect(card).to have_content 'Good'
    end

    it 'overlap message' do
      @fund.update!(
        geographic_scale_limited: true,
        countries: @proposal.countries,
        districts: [@db[:uk_districts].first]
      )
      @proposal.update! districts: @db[:uk_districts]
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports projects in a smaller area than you are seeking.'
      expect(card).to have_content 'Poor'
    end

    it 'national message' do
      @fund.update! geographic_scale_limited: true, national: true
      @proposal.update! affect_geo: 2, district_ids: []
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports national proposals.'
      expect(card).to have_content 'Good'
    end
  end
end
