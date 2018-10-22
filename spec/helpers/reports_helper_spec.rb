require 'rails_helper'

describe ReportsHelper do
  class ReportsHelperClass
    include ActionView::Helpers::NumberHelper
    include ReportsHelper
  end

  subject { ReportsHelperClass.new }

  let(:proposal) { create(:proposal) }

  it '#amount_sought' do
    msg = 'Between £10,000 and £250,000'
    expect(subject.amount_sought(proposal)).to eq(msg)
  end

  it '#location_description' do
    msg = "Local - #{proposal.countries.last.name}"
    expect(subject.location_description(proposal)).to eq(msg)
  end

  context '#recipient_type' do
    it 'individual' do
      proposal.recipient.category_code = 101
      proposal.recipient.description = nil
      expect(subject.recipient_type(proposal.recipient)).to eq('An individual')
    end

    it 'organisation' do
      msg = 'A charitable organisation - Charity registered in England & Wales'
      expect(subject.recipient_type(proposal.recipient)).to eq(msg)
    end
  end

  context '#support_type' do
    it 'with details' do
      proposal.category_code = 101
      proposal.support_details = 'Explanation'
      expect(subject.support_type(proposal)).to eq('Other - Explanation')
    end

    it 'without details' do
      expect(subject.support_type(proposal)).to eq('Revenue - Core')
    end
  end

  it '#themes_description' do
    proposal.themes << build(:theme)
    msg = proposal.themes.pluck(:name).join(' • ')
    expect(subject.themes_description(proposal)).to eq(msg)
  end
end
