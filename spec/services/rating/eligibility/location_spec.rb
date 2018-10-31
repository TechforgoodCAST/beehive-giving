require 'rails_helper'

describe Rating::Eligibility::Location do
  subject { Rating::Eligibility::Location.new(1234, reasons) }

  let(:reasons) do
    {
      'reasons' => [
        {
          'id' => 'countries_ineligible',
          'fund_value' => ['United Kingdom'],
          'proposal_value' => ['Kenya']
        },
        {
          'id' => 'country_outside_area',
          'fund_value' => ['United Kingdom'],
          'proposal_value' => ['United Kingdom', 'Kenya']
        },
        {
          'id' => 'district_outside_area',
          'fund_value' => ['London'],
          'proposal_value' => %w[London Nairobi]
        },
        {
          'id' => 'districts_ineligible',
          'fund_value' => ['London'],
          'proposal_value' => ['Nairobi']
        },
        {
          'id' => 'geographic_scale_ineligible',
          'fund_value' => %w[regional national],
          'proposal_value' => 'local'
        },
        {
          'id' => 'location_eligible'
        }
      ]
    }
  end

  context '#messages' do
    it 'countries_ineligible' do
      message = 'Only supports work in United Kingdom, ' \
                'and you are seeking work in Kenya'
      expect(subject.messages).to include(message)
    end

    it 'country_outside_area' do
      expect(subject.messages).to include('Work in Kenya is not supported')
    end

    it 'district_outside_area' do
      expect(subject.messages).to include('Work in Nairobi is not supported')
    end

    it 'districts_ineligible' do
      message = 'Only supports work in London, ' \
                'and you are seeking work in Nairobi'
      expect(subject.messages).to include(message)
    end

    it 'geographic_scale_ineligible' do
      message = 'Only supports regional and national work, ' \
                'and you are seeking local work'
      expect(subject.messages).to include(message)
    end

    it 'location_eligible' do
      message = "Provides support in the area you're looking for"
      expect(subject.messages).to include(message)
    end
  end
end
