require 'rails_helper'

describe GeoArea do
  subject { build(:geo_area) }

  it('HABTM Countries') { assoc(:countries, :has_and_belongs_to_many) }

  it('HABTM Districts') { assoc(:districts, :has_and_belongs_to_many) }

  it { is_expected.to be_valid }

  it 'countries required' do
    subject.update(countries: [])
    expect_error(:countries, "can't be blank")
  end

  it 'name required' do
    subject.update(name: nil)
    expect_error(:name, "can't be blank")
  end

  it 'districts must be from countries' do
    district = create(:district)
    subject.update(districts: [district])
    msg = "Country '#{district.country.name}' for #{district.name} not selected"

    expect_error(:districts, msg)
  end

  context '#short_name' do
    it 'present' do
      subject.short_name = 'short'
      expect(subject.short_name).to eq('short')
    end

    it 'missing' do
      subject.short_name = nil
      expect(subject.short_name).to eq(subject.name)
    end
  end
end
