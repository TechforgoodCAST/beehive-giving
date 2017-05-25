require 'rails_helper'

describe Fund do
  context 'single' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(save: false)
      @db = @app.instances
      @fund = @db[:funds].first
      @funder = @db[:funder]
    end

    scenario 'districts empty unless geographic_scale_limited' do
      @fund.district_ids = [District.first.id]
      expect(@fund).not_to be_valid
    end

    scenario 'districts required per country if geographic_scale_limited ' \
              'unless fund is national' do
      @fund.geographic_scale_limited = true
      @fund.district_ids = []
      errors = [
        'Districts for United Kingdom not selected',
        'Districts for Kenya not selected'
      ]
      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages).to eq errors
    end

    scenario 'cannot set national unless geographic_scale_limited' do
      @fund.national = true
      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages[0])
        .to eq 'National cannot be set unless geographic scale limited'
    end

    scenario 'districts not allowed if fund is national' do
      @fund.geographic_scale_limited = true
      @fund.national = true
      @fund.district_ids = [District.first.id]

      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages[0])
        .to eq 'Districts must be blank for national funds'
    end

    # TODO: test restriction_ids field

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

    it 'has many funding types'
    #   @fund.save
    #   expect(@fund.funding_types.count).to eq FundingType::FUNDING_TYPE.count
    # end

    it 'amount_min_limited and amount_max_limited present if amount_known'
    #   @fund.amount_min_limited = nil
    #   @fund.amount_max_limited = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'amount_min required if amount_min_limited'
    #   @fund.amount_min = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'amount_max required if amount_max_limited'
    #   @fund.amount_max = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'duration_months_min_limited and duration_months_min_limited present if duration_months_known'
    #   @fund.duration_months_min_limited = nil
    #   @fund.duration_months_max_limited = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'duration_months_min required if duration_months_min_limited'
    #   @fund.duration_months_min = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'duration_months_max required if duration_months_max_limited'
    #   @fund.duration_months_max = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'accepts_calls present if accepts_calls_known'
    #   @fund.accepts_calls = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'contact_number present if accepts_calls'
    #   @fund.contact_number = nil
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'geographic_scale is valid'
    #   const = Proposal::AFFECT_GEO
    #
    #   @fund.geographic_scale = const.first[1] - 1
    #   @fund.save
    #   expect(@fund).not_to be_valid
    #
    #   @fund.geographic_scale = const.last[1] + 1
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'countries present if geographic_scale_limited'
    #   @fund.countries = []
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'districts present if geographic_scale_limited'
    #   @fund.districts = []
    #   @fund.save
    #   expect(@fund).not_to be_valid
    # end

    it 'has many countries'
    #   @fund.save
    #   expect(@fund.countries.count).to eq 2
    # end

    it 'has many districts'
    #   @fund.save
    #   expect(@fund.districts.count).to eq 6
    # end

    it 'restrictions present if restrictions_known' do
      @fund.restrictions = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many restrictions' do
      @fund.save
      expect(@fund.restrictions.count).to eq 5
    end
  end

  context 'multiple' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(num: 2)
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
          .setup_funds(open_data: true)
      @db = @app.instances
      @fund = @db[:funds].first
    end

    it 'requires open data fields' do
      %w(
        period_start period_end grant_count recipient_count amount_awarded_sum
        amount_awarded_mean amount_awarded_median amount_awarded_min
        amount_awarded_max amount_awarded_distribution
        duration_awarded_months_mean duration_awarded_months_median
        duration_awarded_months_min duration_awarded_months_max
        duration_awarded_months_distribution award_month_distribution
        org_type_distribution operating_for_distribution income_distribution
        employees_distribution volunteers_distribution gender_distribution
        age_group_distribution beneficiary_distribution sources
        geographic_scale_distribution country_distribution district_distribution
      ).each do |attribute|
        @fund[attribute] = nil
        expect(@fund).not_to be_valid
      end
    end

    it 'correct attributes greater than or equal to zero' do
      # TODO: %w[
      #   grant_count recipient_count amount_awarded_sum amount_awarded_mean
      #   amount_awarded_median amount_awarded_min amount_awarded_max
      #   duration_awarded_months_mean duration_awarded_months_median
      #   duration_awarded_months_min duration_awarded_months_max
      # ]
      %w(
        grant_count
      ).each do |attribute|
        @fund[attribute] = -1
        expect(@fund).not_to be_valid
        @fund[attribute] = 0
        expect(@fund).to be_valid
      end
    end

    it 'maximum values greater than minimum'
    #   [
    #     %w[amount_awarded_min amount_awarded_max],
    #     %w[duration_awarded_months_min duration_awarded_months_max]
    #   ].each do |attributes|
    #     @fund[attributes[0]] = @fund[attributes[1]] + 1
    #     expect(@fund).not_to be_valid
    #   end
    # end

    it 'period_start is before period_end' do
      @fund.period_start = @fund.period_end + 1
      expect(@fund).not_to be_valid
    end

    it 'period_end is in the past' do
      @fund.period_end = Time.zone.today + 1
      expect(@fund).not_to be_valid
    end

    it 'sources key is valid URL' do
      @fund.sources['wrong'] = 'http://www.example.com'
      expect(@fund).not_to be_valid
      expect(@fund.errors[:sources]).to eq ['Invalid URL - key: wrong']
    end

    it 'sources value is valid URL' do
      @fund.sources['http://www.example.com'] = 'wrong'
      expect(@fund).not_to be_valid
      expect(@fund.errors[:sources]).to eq ['Invalid URL - value: wrong']
    end
  end
end
