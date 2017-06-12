require 'rails_helper'

fdescribe Fund do
  context 'single' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(save: false)
      @db = @app.instances
      @fund = @db[:funds].first
      @funder = @db[:funder]
    end

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

    it 'countries required' do
      @fund.countries = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many countries' do
      @fund.save
      expect(@fund.countries.count).to eq 2
    end

    it 'districts empty unless geographic_scale_limited' do
      @fund.district_ids = [District.first.id]
      expect(@fund).not_to be_valid
    end

    it 'districts required per country if geographic_scale_limited ' \
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

    it 'cannot set national unless geographic_scale_limited' do
      @fund.national = true
      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages[0])
        .to eq 'National cannot be set unless geographic scale limited'
    end

    it 'districts not allowed if fund is national' do
      @fund.geographic_scale_limited = true
      @fund.national = true
      @fund.district_ids = [District.first.id]

      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages[0])
        .to eq 'Districts must be blank for national funds'
    end

    it 'restrictions present if restrictions_known' do
      @fund.restrictions = []
      @fund.save
      expect(@fund).not_to be_valid
    end

    it 'has many restrictions' do
      @fund.save
      expect(@fund.restrictions.count).to eq 5
    end

    it 'saves restriction_ids' do
      @fund.save
      expect(@fund.restriction_ids).to eq @fund.restrictions.pluck(:id)
    end

    it 'min_amount_awarded required if min_amount_awarded_limited' do
      @fund.min_amount_awarded_limited = true
      expect(@fund).not_to be_valid
      @fund.min_amount_awarded = 300
      expect(@fund).to be_valid
    end

    it 'max_amount_awarded required if max_amount_awarded_limited' do
      @fund.max_amount_awarded_limited = true
      expect(@fund).not_to be_valid
      @fund.max_amount_awarded = 10_000
      expect(@fund).to be_valid
    end

    it 'min_duration_awarded required if min_duration_awarded_limited' do
      @fund.min_duration_awarded_limited = true
      expect(@fund).not_to be_valid
      @fund.min_duration_awarded = 300
      expect(@fund).to be_valid
    end

    it 'max_duration_awarded required if max_duration_awarded_limited' do
      @fund.max_duration_awarded_limited = true
      expect(@fund).not_to be_valid
      @fund.max_duration_awarded = 10_000
      expect(@fund).to be_valid
    end

    it 'permitted_costs is either capital or revenue' do
      expect(%w(capital revenue)).to include @fund.permitted_costs
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
        period_start period_end grant_count amount_awarded_distribution
        award_month_distribution org_type_distribution income_distribution
        sources country_distribution
      ).each do |attribute|
        @fund[attribute] = nil
        expect(@fund).not_to be_valid
      end
    end

    it 'correct attributes greater than or equal to zero' do
      %w(
        grant_count
      ).each do |attribute|
        @fund[attribute] = -1
        expect(@fund).not_to be_valid
        @fund[attribute] = 0
        expect(@fund).to be_valid
      end
    end

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
