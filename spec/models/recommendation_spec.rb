require 'rails_helper'

describe Recommendation do
  context 'single' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(open_data: true)
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
      @fund.org_type_distribution[1]['percent'] = 0
      @fund.update_column(:org_type_distribution, @fund.org_type_distribution)
      @proposal.save
      @recommendation.reload
      expect(@recommendation.org_type_score).to eq 0
    end

    it 'has org_type_score'
    #   response =
    #     @fund.org_type_distribution[1]["percent"] +
    #     @fund.operating_for_distribution[2]["percent"] +
    #     @fund.income_distribution[1]["percent"] +
    #     @fund.employees_distribution[0]["percent"] +
    #     @fund.volunteers_distribution[0]["percent"]
    #   expect(@recommendation.org_type_score).to eq response
    # end

    it 'has beneficiary_score from beehive-insight' do
      expect(@recommendation.beneficiary_score).to eq 0.168
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
      expect(@recommendation.grant_amount_recommendation).to eq 0.1
    end

    it 'grant_amount_recommendation is zero if total_costs greater than
        amount_max if amount_max_limited' do
      over_max = 10_001.0
      @app.stub_amounts_endpoint(over_max)
      @proposal.total_costs = over_max
      @proposal.save
      @recommendation.reload
      expect(@recommendation.grant_amount_recommendation).to eq 0
    end

    it 'has grant_duration_recommendation' do
      expect(@recommendation.grant_duration_recommendation).to eq 0.1
    end

    it 'grant_duration_recommendation is zero if funding_duration greater
        than duration_months_max if duration_months_max_limited' do
      over_max = 13
      @app.stub_durations_endpoint(over_max)
      @proposal.funding_duration = over_max
      @proposal.save
      @recommendation.reload
      expect(@recommendation.grant_duration_recommendation).to eq 0
    end

    it 'has total_recommendation' do
      expect(@recommendation.total_recommendation).not_to eq 0
    end
  end

  context 'multiple' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(num: 2, open_data: true)
          .create_recipient
          .create_initial_proposal
      @fund1_recommendation = Recommendation.first
      @fund2_recommendation = Recommendation.last
    end

    it 'slug is unique to proposal and fund' do
      expect(Recommendation.count).to eq 2
      @fund1_recommendation.fund_slug = @fund2_recommendation.fund_slug
      expect { @fund1_recommendation.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      # expect(@fund1_recommendation).not_to be_valid # TODO: https://github.com/zdennis/activerecord-import/wiki/On-Duplicate-Key-Update#conflict-with-activerecord-uniqueness-validation
    end
  end

  it 'only active funds recommended'
  it 'adding fund updates recommendations'
  it 'recommendations ordered by score'
  it 'different proposals have different recommendations'
end
