require 'rails_helper'

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
  let(:method) { :description }

  context '#redact' do
    it 'fund name' do
      expect(subject.redact(fund, method)).not_to have_text('Name')
    end

    it 'funder name' do
      expect(subject.redact(fund, method)).not_to have_text('Super')
    end

    it 'trims' do
      str = subject.redact(fund, method, trim: 5)
      expect(str).not_to have_text('Foundation')
    end

    it 'omission' do
      str = subject.redact(fund, method, trim: 5, omission: 'more')
      expect(str).to have_text('more')
    end

    it 'does not split tags' do
      expect(subject.redact(fund, method, trim: 3)).to have_selector('span')
    end

    it 'accepts different methods' do
      expect(subject.redact(fund, :description_html)).to have_selector('p')
    end
  end
end
