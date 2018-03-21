require 'rails_helper'

describe FilterCell do
  controller ApplicationController

  subject { filter }

  let(:filter) { cell(:filter, params, opts).call(:show) }
  let(:params) { ActionController::Parameters.new }
  let(:opts) { { proposal: proposal, request_path: request_path } }
  let(:proposal) { nil }
  let(:request_path) { nil }

  context 'no active filters' do
    it { is_expected.to have_text('Add filter') }
    it { is_expected.to have_text('None') }
    it { is_expected.not_to have_link('Clear filters') }
  end

  context 'unpermitted params' do
    let(:params) { ActionController::Parameters.new(unpermitted: 'param') }
    it { is_expected.to have_text('Add filter') }
  end

  context 'active filters' do
    let(:params) { ActionController::Parameters.new(eligibility: 'eligible') }

    it { is_expected.to have_text('Edit') }
    it { is_expected.to have_text('eligibility:eligible') }

    context 'clear filters' do
      context 'default path' do
        it { is_expected.to have_link('Clear filters', href: '/funds') }
      end

      context 'request_path' do
        let(:request_path) { '/request/path' }
        it { is_expected.to have_link('Clear filters', href: '/request/path') }
      end
    end

    context 'with proposal' do
      let(:proposal) { build(:proposal, id: 1) }
      it { is_expected.to have_link('Clear filters', href: '/funds/1') }
    end

    it 'selected option' do
      expect(filter).to have_select('eligibility', selected: 'Eligible')
    end

    it 'has country filter' do
      create(:country)
      expect(filter).to have_text('Country')
      expect(filter).to have_text('United Kingdom')
    end

    it 'has eligibility filter' do
      expect(filter).to have_text('Eligibility')
      ['All', 'Eligible', 'Ineligible', 'To check'].each do |option|
        expect(filter).to have_text(option)
      end
    end

    it 'has funding type filter' do
      expect(filter).to have_text('Funding Type')
      %w[All Capital Revenue].each do |option|
        expect(filter).to have_text(option)
      end
    end
  end
end
