require 'rails_helper'

describe Fund do
  context 'single' do

    before(:each) do
      @app.seed_test_db
          .setup_funds
      @db = @app.instances
      @fund = @db[:funds].first
      @funder = @db[:funder]
    end

    it 'generates summary for last 12 months from most recent grant'
    it 'org_type_distribution has correct format'
    # TODO: remaining distribution fields
    # it 'distribution fields have uique positions' # TODO: refactor beehive-data
    # it 'distribution fields total 100 percent' # TODO: refactor beehive-data

    it 'is valid' do
      expect(@fund).to be_valid
    end

    it 'belongs to funder' do
      expect(@fund.funder.name).to eq @funder.name
    end

    it 'without funder is invalid' do
      @fund.funder = nil
      expect(@fund).not_to be_valid
    end

    it 'has many deadlines' do
      @fund.save
      expect(@fund.deadlines.count).to eq 2
    end

    it 'deadlines required if deadlines_known and deadlines_limited' do
      @fund.deadlines_limited = true
      @fund.deadlines = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'deadlines not required if deadlines not limited' do
      @fund.deadlines_limited = false
      @fund.deadlines = []
      @fund.save
      expect(@fund).to be_valid
    end

    it 'has many stages' do
      @fund.save
      expect(@fund.stages.count).to eq 2
    end

    it 'stages required if stages_known' do
      @fund.stages = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many funding types' do
      @fund.save
      expect(@fund.funding_types.count).to eq FundingType::FUNDING_TYPE.count
    end

    it 'amount_min_limited and amount_max_limited present if amount_known' do
      @fund.amount_min_limited = nil
      @fund.amount_max_limited = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'amount_min required if amount_min_limited' do
      @fund.amount_min = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'amount_max required if amount_max_limited' do
      @fund.amount_max = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'duration_months_min_limited and duration_months_min_limited present if duration_months_known' do
      @fund.duration_months_min_limited = nil
      @fund.duration_months_max_limited = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'duration_months_min required if duration_months_min_limited' do
      @fund.duration_months_min = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'duration_months_max required if duration_months_max_limited' do
      @fund.duration_months_max = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'accepts_calls present if accepts_calls_known' do
      @fund.accepts_calls = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'contact_number present if accepts_calls' do
      @fund.contact_number = nil
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'geographic_scale is valid' do
      const = Proposal::AFFECT_GEO

      @fund.geographic_scale = const.first[1] - 1
      @fund.save
      expect(@fund).not_to be_valid

      @fund.geographic_scale = const.last[1] + 1
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'countries present if geographic_scale_limited' do
      @fund.countries = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'districts present if geographic_scale_limited' do
      @fund.districts = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many countries' do
      @fund.save
      expect(@fund.countries.count).to eq 2
    end

    it 'has many districts' do
      @fund.save
      expect(@fund.districts.count).to eq 6
    end

    it 'restrictions present if restrictions_known' do
      @fund.restrictions = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many restrictions' do
      @fund.save
      expect(@fund.restrictions.count).to eq 2
    end

    it 'outcomes present if outcomes_known' do
      @fund.outcomes = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many outcomes' do
      @fund.save
      expect(@fund.outcomes.count).to eq 2
    end

    it 'decision_makes present if decision_makers_known' do
      @fund.decision_makers = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many decision_makers' do
      @fund.save
      expect(@fund.decision_makers.count).to eq 2
    end
  end

  context 'multiple' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(2, true)
      @db = @app.instances
      @fund1 = @db[:funds].first
      @fund2 = @db[:funds].last
      @funder = @db[:funder]
    end

    it 'name is unique to funder' do
      @fund1.name = @fund2.name
      expect(@fund1).not_to be_valid
    end
  end

  context 'with open date' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(1, true, true)
      @db = @app.instances
      @fund = @db[:funds].first
    end

    it 'requires open data fields' do
      %w[period_start period_end grant_count recipient_count amount_mean_historic
      amount_median_historic amount_min_historic amount_max_historic
      duration_months_mean_historic duration_months_median_historic
      duration_months_min_historic duration_months_max_historic
      org_type_distribution operating_for_distribution income_distribution
      employees_distribution volunteers_distribution geographic_scale_distribution
      beneficiary_min_age_historic beneficiary_max_age_historic
      gender_distribution].each do |attribute|
        @fund[attribute] = nil
        expect(@fund).not_to be_valid
      end
    end

    it 'correct attributes greater than zero' do
      %w[grant_count recipient_count amount_mean_historic
      amount_median_historic amount_min_historic amount_max_historic
      duration_months_mean_historic duration_months_median_historic
      duration_months_min_historic duration_months_max_historic
      beneficiary_max_age_historic].each do |attribute|
        @fund[attribute] = 0
        expect(@fund).not_to be_valid
      end
    end

    it 'correct attributes greater than or equal to zero' do
      %w[beneficiary_min_age_historic].each do |attribute|
        @fund[attribute] = -1
        expect(@fund).not_to be_valid
      end
    end

    it 'maximum values greater than minimum' do
      [
        %w[amount_min_historic amount_max_historic],
        %w[duration_months_min_historic duration_months_max_historic],
        %w[beneficiary_min_age_historic beneficiary_max_age_historic]
      ].each do |attributes|
        @fund[attributes[0]] = @fund[attributes[1]] + 1
        expect(@fund).not_to be_valid
      end
    end

    it 'period_start is before period_end' do
      @fund.period_start = @fund.period_end + 1
      expect(@fund).not_to be_valid
    end

    it 'period_end is in the past' do
      @fund.period_end = Date.today + 1
      expect(@fund).not_to be_valid
    end
  end
end
