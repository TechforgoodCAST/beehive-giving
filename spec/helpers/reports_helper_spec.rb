require 'rails_helper'

describe ReportsHelper do
  class ReportsHelperClass
    include ActionView::Helpers
    include Rails.application.routes.url_helpers
    include ReportsHelper
  end

  subject { ReportsHelperClass.new }

  let(:proposal) { create(:proposal) }
  let(:recipient) { proposal.recipient }

  it '#amount_sought' do
    msg = 'Between £10,000 and £250,000'
    expect(subject.amount_sought(proposal)).to eq(msg)
  end

  context '#created_by' do
    it 'individual' do
      recipient.category_code = 101
      expect(subject.created_by(recipient)).to eq('an individual')
    end

    it 'organisation' do
      expect(subject.created_by(recipient)).to eq(recipient.name)
    end
  end

  it '#location_description' do
    msg = "Local - #{proposal.countries.last.name}"
    expect(subject.location_description(proposal)).to eq(msg)
  end

  context '#recipient_type' do
    it 'individual' do
      recipient.category_code = 101
      recipient.description = nil
      expect(subject.recipient_type(recipient)).to eq('An individual')
    end

    it 'organisation' do
      msg = 'A charitable organisation - Charity registered in England & Wales'
      expect(subject.recipient_type(recipient)).to eq(msg)
    end
  end

  context '#recipient_name' do
    it 'individual' do
      recipient.category_code = 101
      recipient.description = nil
      expect(subject.recipient_name(recipient)).to eq('An individual')
    end

    it 'organisation' do
      msg = 'Charity projects'
      expect(subject.recipient_name(proposal.recipient)).to eq(msg)
    end
  end

  context '#report_button' do
    it 'public' do
      expect(subject.report_button(proposal)).to have_css('.blue')
    end

    it 'private' do
      proposal.private = Time.zone.now
      expect(subject.report_button(proposal)).to have_css('.disabled')
    end
  end

  it '#spot_mistake_form_url' do
    url = 'https://docs.google.com/forms/d/e/1FAIpQLSeOkkh1Ecb43lOQd2wDe_3ueL' \
          'VpX46uNxjngJRIV2VpSUKMag/viewform?usp=pp_url&entry.1646333123=http' \
          's://www.beehivegiving.org/path?param=1'
    expect(subject.spot_mistake_form_url('/path?param=1')).to eq(url)
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
