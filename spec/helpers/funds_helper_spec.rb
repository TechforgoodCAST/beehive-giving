require 'rails_helper'
include ActionView::Helpers::SanitizeHelper

describe FundsHelper do
  subject { Class.new.include(FundsHelper).new }

  let(:funder_name) { 'Super Foundation' }
  let(:fund_name) { 'Social Change Fund' }
  let(:fund) do
    build(
      :fund,
      funder: build(:funder, name: funder_name),
      name: fund_name,
      description: "A description #{fund_name} #{funder_name}"
    )
  end
  let(:field) { :description }

  context '#redact' do
    it 'fund name' do
      expect(subject.redact(fund, field)).not_to have_text('Name')
    end

    it 'funder name' do
      expect(subject.redact(fund, field)).not_to have_text('Super')
    end

    it 'trims' do
      str = subject.redact(fund, field, trim: 5)
      expect(str).not_to have_text('Foundation')
    end

    it 'omission' do
      str = subject.redact(fund, field, trim: 5, omission: 'more')
      expect(str).to have_text('more')
    end

    it 'does not split tags' do
      expect(subject.redact(fund, field, trim: 3)).to have_selector('span')
    end
  end
end
