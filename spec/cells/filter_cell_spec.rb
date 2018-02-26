require 'rails_helper'

describe FilterCell do
  controller ApplicationController

  subject { filter }

  let(:filter) { cell(:filter, params, proposal: proposal).call(:show) }
  let(:params) { ActionController::Parameters.new }
  let(:proposal) { nil }

  context 'no active filters' do
    it { is_expected.to have_text('Add filter') }
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

    it { is_expected.to have_link('Clear all filters', href: '/funds') }
    it { is_expected.to have_text('duration:all, eligibility:eligible') }

    context 'with proposal' do
      let(:proposal) { build(:proposal, id: 1) }
      it { is_expected.to have_link('Clear all filters', href: '/funds/1') }
    end
  end
end
