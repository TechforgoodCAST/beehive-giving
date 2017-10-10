require 'rails_helper'

describe FundCardCell do
  controller ApplicationController

  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.create_registered_proposal
    @db = @app.instances
    @fund = Fund.last
    @proposal = Proposal.last
  end

  def proposal(score, reason)
    @proposal.suitability = {
      @fund.slug => {
        'location' => { 'score' => score, 'reason' => reason }
      }
    }
  end

  context '#location' do
    it 'ineligible message' do
      @proposal.update_column :eligibility, @fund.slug => { 'location' => false }
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Does not fund the areas in your proposal.'
      expect(card).to have_link 'Ineligible'
    end

    it 'anywhere message' do
      proposal(1, 'anywhere')
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Accepts proposals from anywhere in the country.'
      expect(card).to have_content 'Good'
    end

    it 'exact message' do
      proposal(1, 'exact')
      @fund.geo_area.update!(
        countries: @proposal.countries,
        districts: @proposal.districts
      )
      @fund.update!(
        geographic_scale_limited: true
      )
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports all of the areas in your proposal.'
      expect(card).to have_content 'Good'
    end

    it 'intersect message' do
      proposal(0, 'intersect')
      @fund.geo_area.update!(
        countries: @proposal.countries,
        districts: @db[:uk_districts].take(2)
      )
      @fund.update!(
        geographic_scale_limited: true,
      )
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports some of the areas in your proposal.'
      expect(card).to have_content 'Neutral'
    end

    it 'partial message' do
      proposal(1, 'partial')
      @fund.geo_area.update!(
        countries: @proposal.countries,
        districts: @db[:uk_districts].take(2)
      )
      @fund.update!(
        geographic_scale_limited: true,
      )
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports all of the areas in your proposal.'
      expect(card).to have_content 'Good'
    end

    it 'overlap message' do
      proposal(-1, 'overlap')
      @fund.geo_area.update!(
        countries: @proposal.countries,
        districts: [@db[:uk_districts].first]
      )
      @fund.update!(
        geographic_scale_limited: true,
      )
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports projects in a smaller area than you are seeking.'
      expect(card).to have_content 'Poor'
    end

    it 'national message' do
      proposal(1, 'national')
      @fund.update! geographic_scale_limited: true, national: true
      card = cell(:fund_card, @proposal, fund: @fund).call(:location)
      expect(card).to have_content 'Supports national proposals.'
      expect(card).to have_content 'Good'
    end
  end
end
