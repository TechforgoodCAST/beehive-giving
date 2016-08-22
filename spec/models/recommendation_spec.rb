require 'rails_helper'

describe Recommendation do
  context 'single' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(1, true, true)
          .create_recipient
          .create_initial_proposal
      @db = @app.instances
      @fund = Fund.first
      @recommendation = Recommendation.first
      @proposal = @db[:initial_proposal]
    end

    it 'belongs to proposal' do
      expect(@recommendation.proposal).to eq @proposal
    end

    it 'belongs to fund' do
      expect(@recommendation.fund).to eq @fund
    end

    it 'is valid' do
      expect(@recommendation).to be_valid
    end

    it 'is invalid' do
      @recommendation.fund = nil
      expect(@recommendation).not_to be_valid
    end

    it 'sets fund_slug when created' do
      expect(@recommendation.fund_slug).to eq @fund.slug
    end

    it 'org_type with 0 match returns 0 overall' do
      @fund.org_type_distribution[1]["percentage"] = 0
      @fund.update_column(:org_type_distribution, @fund.org_type_distribution)
      @proposal.save
      @recommendation.reload
      expect(@recommendation.org_type_score).to eq 0
    end

    it 'has org_type_score' do
      response =
        @fund.org_type_distribution[1]["percentage"] +
        @fund.operating_for_distribution[2]["percentage"] +
        @fund.income_distribution[1]["percentage"] +
        @fund.employees_distribution[0]["percentage"] +
        @fund.volunteers_distribution[0]["percentage"]
      expect(@recommendation.org_type_score).to eq response
    end

    it 'has beneficiary_score from beehive-insight' do
      expect(@recommendation.beneficiary_score).to eq 0.568
    end

    it 'beneficiary_score zero if beehive-insight fund not found' do
      @fund.update_column(:slug, 'missing-fund')
      @proposal.save
      @recommendation.reload
      expect(@recommendation.beneficiary_score).to eq 0
    end

    it 'has location_score' do
      expect(@recommendation.location_score).to eq 2
    end

    it 'has grant_amount_recommendation' do
      expect(@recommendation.grant_amount_recommendation).to eq 0.5
    end

    it 'grant_amount_recommendation is zero if total_costs greater than amount_max if amount_known' do
      over_max = 10001.0
      @app.stub_beehive_insight_amounts(over_max)
      @proposal.total_costs = over_max
      @proposal.save
      @recommendation.reload
      expect(@recommendation.grant_amount_recommendation).to eq 0
    end

    # it 'has grant_duration_recommendation'
    # it 'grant_duration_recommendation is zero if beyond fund range'
    # it 'has total_recommendation'
    # it 'has state'
  end

  context 'multiple' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(2, true)
          .create_recipient
          .create_initial_proposal
      @fund1_recommendation = Recommendation.first
      @fund2_recommendation = Recommendation.last
    end

    it 'slug is unique to proposal and fund' do
      @fund1_recommendation.fund_slug = @fund2_recommendation.fund_slug
      expect { @fund1_recommendation.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      expect(@fund1_recommendation).not_to be_valid
    end
  end
end
