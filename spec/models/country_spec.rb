require 'rails_helper'

describe Country do
  subject { build(:country) }

  it('has many Districts') { assoc(:districts, :has_many) }

  it('has many Funds') { assoc(:funds, :has_many, through: :geo_areas) }

  it('has many Funders') { assoc(:funders, :has_many, through: :funds) }

  it('HABTM GeoAreas') { assoc(:geo_areas, :has_and_belongs_to_many) }

  it('HABTM Proposals') { assoc(:proposals, :has_and_belongs_to_many) }

  it { is_expected.to be_valid }

  context 'unique' do
    before { subject.save }

    it 'name' do
      expect(build(:country, name: subject.name)).not_to be_valid
    end

    it 'alpha2' do
      expect(build(:country, alpha2: subject.alpha2)).not_to be_valid
    end
  end
end
