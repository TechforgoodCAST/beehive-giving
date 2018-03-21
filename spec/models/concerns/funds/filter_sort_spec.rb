require 'rails_helper'

describe Funds::FilterSort do
  subject { Fund.filter_sort(proposal, params) }

  let(:proposal) { build(:proposal) }
  let(:params) { {} }

  before(:each) do
    default_order = %i[orphan eligible incomplete ineligible]
    @funds = default_order.zip(create_list(:fund_simple, 4)).to_h
    default_order.drop(1).each do |label|
      create(label, fund: @funds[label], proposal: proposal)
    end
  end

  context '#country' do
    context 'default all' do
      it { is_expected.to contain_exactly(*@funds.values) }
    end

    context 'alpha2' do
      before do
        @funds[:eligible].update(
          geo_area: create(:geo_area, countries: [Country.last])
        )
      end

      let(:params) { { country: Country.last.alpha2 } }

      it { expect(subject.size).to eq(1) }
    end
  end

  context '#eligibility' do
    context 'default all' do
      it { is_expected.to contain_exactly(*@funds.values) }
    end

    context 'eligible' do
      let(:params) { { eligibility: 'eligible' } }
      it { is_expected.to contain_exactly(@funds[:eligible]) }
    end

    context 'ineligible' do
      let(:params) { { eligibility: 'ineligible' } }
      it { is_expected.to contain_exactly(@funds[:ineligible]) }
    end

    context 'to-check' do
      let(:params) { { eligibility: 'to-check' } }
      let(:funds) { [@funds[:orphan], @funds[:incomplete]] }
      it { is_expected.to contain_exactly(*funds) }
    end
  end

  context '#funding_type' do
    context 'default all' do
      it { is_expected.to contain_exactly(*@funds.values) }
    end

    context do
      before { @funds[:eligible].update_column(:permitted_costs, []) }

      context 'capital' do
        let(:params) { { type: 'capital' } }
        it { expect(subject.size).to eq(3) }
      end

      context 'revenue' do
        let(:params) { { type: 'revenue' } }
        it { expect(subject.size).to eq(3) }
      end
    end
  end

  context '#order_by' do
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

    context 'name' do
      before { @funds[:ineligible].update(name: '0') }
      let(:params) { { sort: 'name' } }

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

  context '#revealed' do
    context 'default all' do
      it { is_expected.to contain_exactly(*@funds.values) }
    end

    context 'revealed' do
      before { Assessment.last.update(revealed: true) }
      let(:params) { { revealed: true } }

      it { is_expected.to contain_exactly(@funds[:ineligible]) }
    end
  end

  context '#select_view_columns' do
    subject { Fund.filter_sort(proposal, params).first }

    it { is_expected.to respond_to(:assessment_id) }
    it { is_expected.to respond_to(:proposal_id) }
    it { is_expected.to respond_to(:eligibility_status) }
    it { is_expected.to respond_to(:revealed) }
  end

  it 'no proposal'
  it 'only active funds'
  it 'ineligible featured fund'
  it 'revealed funds ordered first in each eligibility state'
end
