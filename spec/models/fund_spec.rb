require 'rails_helper'

describe Fund do
  context 'self.order_by' do
    let(:proposal) { build(:proposal) }

    before(:each) do
      default_order = %i[orphan eligible incomplete ineligible]
      @funds = default_order.zip(create_list(:fund_simple, 4)).to_h
      default_order.drop(1).each do |label|
        create(label, fund: @funds[label], proposal: proposal)
      end
    end

    subject { Fund.order_by(proposal) }

    it 'no proposal'

    it 'default order' do
      expect(subject).to eq(@funds.values)
    end

    it 'only active funds' do
      expect(subject.pluck(:state).uniq).to eq(['active'])
    end

    it 'deactivated fund' do
      @funds[:eligible].update(state: 'inactive')
      expect(subject.size).to eq(3)
    end

    it 'featured fund is ordered first if eligible' do
      @funds[:incomplete].update(featured: true)
      featured_order = [
        @funds[:incomplete],
        @funds[:orphan],
        @funds[:eligible],
        @funds[:ineligible]
      ]
      expect(subject).to eq(featured_order)
    end

    it 'ineligible featured fund'

    context 'name' do
      before { @funds[:ineligible].update(name: '0') }

      it 'ASC' do
        expect(Fund.order_by(proposal, 'name')[0]).to eq(@funds[:ineligible])
      end

      it 'featured fund first' do
        @funds[:incomplete].update(featured: true)
        expect(Fund.order_by(proposal, 'name')[0]).to eq(@funds[:incomplete])
        expect(Fund.order_by(proposal, 'name')[1]).to eq(@funds[:ineligible])
      end
    end
  end

  context 'single' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(num: 3)
      @db = @app.instances
      @fund = @db[:funds].first
      @funder = @db[:funder]
    end

    it '#save draft or stub' do
      @fund.state = 'draft'
      @fund.key_criteria = nil
      expect(@fund.save).to eq true
    end

    it '#save active or inactive' do
      @fund.key_criteria = nil
      expect(@fund.save).to eq false
    end

    context '#state' do
      it 'defaults to draft' do
        expect(subject.state).to eq 'draft'
      end

      it 'state is in list' do
        @fund.state = 'Not valid state'
        expect(@fund).not_to be_valid
      end

      it 'self.active' do
        Fund.last.update state: 'inactive'
        expect(Fund.active.count).to eq 2
      end
    end

    context 'self.eligibility' do
      before(:each) do
        @eligibility = Fund.all.each_with_index.map do |fund, i|
          [fund.slug, { 'quiz' => { 'eligible' => i.even? } }]
        end.to_h
        @proposal = build(:proposal, eligibility: @eligibility)
      end

      it 'default all' do
        expect(Fund.eligibility(@proposal, 'DROP TABLE "FUNDS";').size).to eq 3
      end

      it 'eligible' do
        expect(Fund.eligibility(@proposal, 'eligible').size).to eq 2
      end

      it 'ineligible' do
        expect(Fund.eligibility(@proposal, 'ineligible').size).to eq 1
      end
    end

    context 'self.duration' do
      before(:each) do
        Fund.first.update(min_duration_awarded: 6, max_duration_awarded: 36)
        Fund.second.update(min_duration_awarded: 12)
        @proposal = build(:proposal, funding_duration: 12)
      end

      it 'up-to-2y' do
        expect(Fund.duration(@proposal, 'up-to-2y').size).to eq 2
      end

      it '2y-plus' do
        expect(Fund.duration(@proposal, '2y-plus').size).to eq 1
      end

      it 'proposal min only' do
        expect(Fund.duration(@proposal, 'proposal').size).to eq 2
      end

      it 'proposal max only' do
        Fund.second.update(min_duration_awarded: nil, max_duration_awarded: 12)
        expect(Fund.duration(@proposal, 'proposal').size).to eq 2
      end

      it 'proposal exact' do
        Fund.second.update(min_duration_awarded: 12, max_duration_awarded: 12)
        expect(Fund.duration(@proposal, 'proposal').size).to eq 2
      end

      it 'proposal over' do
        Fund.second.update(min_duration_awarded: 3, max_duration_awarded: 9)
        expect(Fund.duration(@proposal, 'proposal').size).to eq 1
      end

      it 'proposal under' do
        Fund.second.update(min_duration_awarded: 18, max_duration_awarded: 24)
        expect(Fund.duration(@proposal, 'proposal').size).to eq 1
      end

      it 'all' do
        expect(Fund.duration(@proposal, 'all').size).to eq 3
      end
    end

    it '#description_redacted' do
      @fund.description += @fund.name + ' ' + @fund.funder.name
      expect(@fund.description_redacted).not_to include @fund.name
      expect(@fund.description_redacted).not_to include @fund.funder.name
    end

    it 'is valid' do
      expect(@fund).to be_valid
    end

    it 'belongs to funder' do
      expect(@fund.funder.name).to eq @funder.name
    end

    it 'has many fund_themes' do
      expect(@fund.fund_themes.count).to eq 3
    end

    it 'has many themes' do
      expect(@fund.themes.count).to eq 3
    end

    it 'has at least one theme' do
      @fund.themes = []
      expect(@fund).not_to be_valid
    end

    it 'without funder is invalid' do
      @fund.funder = nil
      expect(@fund).not_to be_valid
    end

    # move to geo_area?
    it 'has many countries' do
      @fund.save
      expect(@fund.countries.count).to eq 2
    end

    # move to geo_area?
    it 'districts empty unless geographic_scale_limited' do
      @fund.geo_area.update!(districts: [District.first])
      expect(@fund).not_to be_valid
    end

    # move to geo_area?
    it 'districts required per country if geographic_scale_limited ' \
       'unless fund is national' do
      @fund.geographic_scale_limited = true
      @fund.geo_area.update!(districts: [])
      errors = [
        'Districts for United Kingdom not selected',
        'Districts for Kenya not selected'
      ]
      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages).to eq errors
    end

    # move to geo_area?
    it 'cannot set national unless geographic_scale_limited' do
      @fund.national = true
      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages[0])
        .to eq 'National cannot be set unless geographic scale limited'
    end

    # move to geo_area?
    it 'districts not allowed if fund is national' do
      @fund.geographic_scale_limited = true
      @fund.national = true
      @fund.geo_area.update!(districts: [District.first])

      expect(@fund).not_to be_valid
      expect(@fund.errors.full_messages[0])
        .to eq 'Districts must be blank for national funds'
    end

    it 'restrictions present if restrictions_known' do
      @fund.restrictions = []
      expect(@fund).not_to be_valid
    end

    it 'has many restrictions' do
      @fund.save
      expect(@fund.restrictions.count).to eq 5
    end

    it 'min_amount_awarded required if min_amount_awarded_limited' do
      @fund.min_amount_awarded_limited = true
      @fund.min_amount_awarded = nil
      expect(@fund).not_to be_valid
      @fund.min_amount_awarded = 300
      expect(@fund).to be_valid
    end

    it 'max_amount_awarded required if max_amount_awarded_limited' do
      @fund.max_amount_awarded_limited = true
      @fund.max_amount_awarded = nil
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

    it 'array fields valid' do
      %i[permitted_org_types permitted_costs].each do |attribute|
        @fund[attribute] = nil
        expect(@fund).not_to be_valid
        @fund[attribute] = []
        expect(@fund).not_to be_valid
        @fund[attribute] = [1, -100]
        expect(@fund).not_to be_valid
        @fund[attribute] = [1, 2]
        expect(@fund).to be_valid
      end
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
      %w[
        period_start period_end grant_count amount_awarded_distribution
        award_month_distribution org_type_distribution income_distribution
        sources country_distribution
      ].each do |attribute|
        @fund[attribute] = nil
        expect(@fund).not_to be_valid
      end
    end

    it 'correct attributes greater than or equal to zero' do
      %w[
        grant_count
      ].each do |attribute|
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
