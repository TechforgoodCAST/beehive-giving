fdescribe FundStub do
  subject { FundStub.new(name: 'Main Fund', funder: funder, description: 'Desc') }
  let(:funder) { build(:funder) }

  context 'single' do
    it 'requires funder' do
      subject.funder = nil
      is_expected.not_to be_valid
    end

    it '#funder is Funder object' do
      subject.funder = 'Funder'
      is_expected.not_to be_valid
    end

    it 'requires name' do
      subject.name = nil
      is_expected.not_to be_valid
    end

    it 'belongs to funder' do
      subject.funder = funder
      expect(subject.funder.name).to eq funder.name
    end

    it 'requires description' do
      subject.description = nil
      is_expected.not_to be_valid
    end

    it 'requires themes' do
      subject.themes = nil
      is_expected.not_to be_valid
    end

    it 'themes is an Array' do
      subject.themes = 'themes'
      is_expected.not_to be_valid
    end

    it 'requires geo_area' do
      subject.geo_area = nil
      is_expected.not_to be_valid
    end

    it '#geo_area is GeoArea object' do
      subject.geo_area = 'Geo area'
      is_expected.not_to be_valid
    end

    # permitted_costs is empty

    # other validations not needed
  end
end