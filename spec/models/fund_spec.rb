# rubocop:disable Style/NumericLiterals

require 'rails_helper'

describe Fund do
  context 'self' do
    let(:proposal) { build(:proposal) }

    before(:each) do
      default_order = %i[orphan eligible incomplete ineligible]
      @funds = default_order.zip(create_list(:fund_simple, 4)).to_h
      default_order.drop(1).each do |label|
        create(label, fund: @funds[label], proposal: proposal)
      end
    end

    it '#version' do
      Fund.update_all(updated_at: DateTime.new(2018, 1, 1).in_time_zone)
      expect(Fund.version).to eq(269159070)
    end

    context '#order_by' do
      subject { Fund.join(proposal).order_by(col) }

      let(:col) { nil }

      it 'no proposal'
      it 'only active funds'

      context 'default order' do
        it { is_expected.to contain_exactly(*@funds.values) }
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

      it 'revealed funds ordered first in each eligibility state'

      context 'name' do
        before { @funds[:ineligible].update(name: '0') }
        let(:col) { 'name' }

        it 'ASC' do
          expect(subject[0]).to eq(@funds[:ineligible])
        end

        it 'featured fund first' do
          @funds[:incomplete].update(featured: true)
          expect(subject[0]).to eq(@funds[:incomplete])
          expect(subject[1]).to eq(@funds[:ineligible])
        end
      end
    end

    context '#funding_type' do
      subject { Fund.join(proposal).funding_type(funding_type) }
      let(:funding_type) { nil }

      context 'default all' do
        it { is_expected.to contain_exactly(*@funds.values) }
      end

      context do
        before { @funds[:eligible].update_column(:permitted_costs, []) }

        context 'capital' do
          let(:funding_type) { 'capital' }
          it { expect(subject.size).to eq(3) }
        end

        context 'revenue' do
          let(:funding_type) { 'revenue' }
          it { expect(subject.size).to eq(3) }
        end
      end
    end

    context '#eligibility' do
      subject { Fund.join(proposal).eligibility(eligibility) }

      let(:eligibility) { nil }

      context 'default all' do
        it { is_expected.to contain_exactly(*@funds.values) }
      end

      context 'eligible' do
        let(:eligibility) { 'eligible' }
        it { is_expected.to contain_exactly(@funds[:eligible]) }
      end

      context 'ineligible' do
        let(:eligibility) { 'ineligible' }
        it { is_expected.to contain_exactly(@funds[:ineligible]) }
      end

      context 'to-check' do
        let(:eligibility) { 'to-check' }
        let(:funds) { [@funds[:orphan], @funds[:incomplete]] }
        it { is_expected.to contain_exactly(*funds) }
      end
    end

    context '#country' do
      subject { Fund.join(proposal).country(country) }

      let(:country) { nil }

      context 'default all' do
        it { is_expected.to contain_exactly(*@funds.values) }
      end

      context 'alpha2' do
        before do
          @funds[:eligible].update(
            geo_area: create(:geo_area, countries: [Country.last])
          )
        end
        let(:country) { Country.last.alpha2 }
        it { expect(subject.size).to eq(1) }
      end
    end

    context '#revealed' do
      subject { Fund.join(proposal).revealed(revealed) }

      let(:revealed) { nil }

      context 'default all' do
        it { is_expected.to contain_exactly(*@funds.values) }
      end

      context 'revealed' do
        before { Assessment.last.update(revealed: true) }
        let(:revealed) { true }

        it { is_expected.to contain_exactly(@funds[:ineligible]) }
      end
    end
  end

  context do
    subject { build(:fund) }

    let(:hidden) { 'Hidden fund' }

    it '#pretty_name default' do
      expect(subject.pretty_name).to eq(hidden)
    end

    it '#pretty_name if empty string' do
      subject.pretty_name = ''
      expect(subject.pretty_name).to eq(hidden)
    end

    it '#pretty_name if present' do
      subject.pretty_name = 'Pretty name'
      expect(subject.pretty_name).to eq('Pretty name')
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
