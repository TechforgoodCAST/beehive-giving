require 'rails_helper'

describe District do
  subject { build(:district, country: country) }

  let(:country) { create(:country) }

  it('belongs_to Country') { assoc(:country, :belongs_to) }

  it('has many Funds') { assoc(:funds, :has_many, through: :geo_areas) }

  it('has many Funders') { assoc(:funders, :has_many, through: :funds) }

  it('HABTM GeoAreas') { assoc(:geo_areas, :has_and_belongs_to_many) }

  it('HABTM Proposals') { assoc(:proposals, :has_and_belongs_to_many) }

  it('has many Recipients') { assoc(:recipients, :has_many) }

  it { is_expected.to be_valid }

  it 'unique per country' do
    subject.save
    duplicate = build(:district, name: subject.name, country: country)
    expect(duplicate).not_to be_valid
  end
end
