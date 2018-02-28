require 'rails_helper'

describe FilterCell do
  controller ApplicationController

  subject { filter }

  let(:duration) { 12 }
  let(:filter) do
    cell(
      :filter, params, funding_duration: duration, proposal: proposal
    ).call(:show)
  end
  let(:params) { ActionController::Parameters.new }
  let(:proposal) { nil }

  context 'no active filters' do
    it { is_expected.to have_text('Add filter') }
    it { is_expected.to have_text('None') }
    it { is_expected.not_to have_link('Clear all filters') }
  end

  context 'unpermitted params' do
    let(:params) { ActionController::Parameters.new(unpermitted: 'param') }
    it { is_expected.to have_text('Add filter') }
  end

  context 'active filters' do
    let(:params) do
      ActionController::Parameters.new(eligibility: 'eligible', duration: 'all')
    end

    it { is_expected.to have_text('Edit') }
    it { is_expected.to have_link('Clear filters', href: '/funds') }
    it { is_expected.to have_text('duration:all, eligibility:eligible') }

    context 'with proposal' do
      let(:proposal) { build(:proposal, id: 1) }
      it { is_expected.to have_link('Clear filters', href: '/funds/1') }
    end

    it 'has eligibility filter' do
      expect(filter).to have_text('Eligibility')
      ['All', 'Eligible', 'Ineligible', 'To check'].each do |option|
        expect(filter).to have_text(option)
      end
    end

    it 'has funding duration filter' do
      expect(filter).to have_text('Funding Duration')
      [
        'Your proposal (12 months)', 'Up to 2 years', 'More than 2 years'
      ].each do |option|
        expect(filter).to have_text(option)
      end
    end

    context 'funding duration missing' do
      let(:duration) { nil }
      it { is_expected.not_to have_text('Your proposal') }
    end

    it 'selected option' do
      expect(filter).to have_select('eligibility', selected: 'Eligible')
    end
  end
end
