require 'rails_helper'

describe Rating::Eligibility::Location do
  subject { Rating::Eligibility::Location.new(1234, reasons) }

  let(:countries) { create_list(:country, 2) }
  let(:districts) { create_list(:district, 2) }

  let(:reasons) do
    {
      'reasons' => [
        {
          'id' => 'countries_ineligible',
          'fund_value' => [countries[0].id],
          'proposal_value' => [countries[1].id]
        },
        {
          'id' => 'country_outside_area',
          'fund_value' => [countries[0].id],
          'proposal_value' => countries.pluck(:id)
        },
        {
          'id' => 'district_outside_area',
          'fund_value' => [districts[0].id],
          'proposal_value' => districts.pluck(:id)
        },
        {
          'id' => 'districts_ineligible',
          'fund_value' => [districts[0].id],
          'proposal_value' => [districts[1].id]
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
      message = "Does not support work in #{countries[1].name}"
      expect(subject.messages).to include(message)
    end

    it 'country_outside_area' do
      message = "Work in #{countries[1].name} is not supported"
      expect(subject.messages).to include(message)
    end

    it 'district_outside_area' do
      message = "Work in #{districts[1].name} is not supported"
      expect(subject.messages).to include(message)
    end

    it 'districts_ineligible' do
      message = "Does not support work in #{districts[1].name}"
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
