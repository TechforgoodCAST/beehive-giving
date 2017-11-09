describe FundStub do
  subject do
    FundStub.new(
      name: 'Main Fund',
      funder: funder,
      description: 'Desc',
      themes: [],
      geo_area: GeoArea.new
    )
  end
  let(:funder) { build(:funder) }

  it 'can be initalized with attributes' do
    expect(subject.name).to eq 'Main Fund'
  end

  it 'can be initalized with existing funds attributes' do
    fund = Fund.new(name: 'Existing fund')
    expect(FundStub.new(name: 'Fund', fund: fund).name).to eq 'Existing fund'
  end

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

  it 'does not require themes' do
    subject.themes = nil
    expect(subject.state).to eq 'draft'
    is_expected.to be_valid
  end

  context 'not draft' do
    before { subject.fund = Fund.new(state: 'stub') }

    it 'requires themes' do
      subject.themes = nil
      is_expected.not_to be_valid
    end

    it 'themes is an Array' do
      subject.themes = 'themes'
      is_expected.not_to be_valid
    end
  end

  it 'requires geo_area' do
    subject.geo_area = nil
    is_expected.not_to be_valid
  end

  it '#geo_area is GeoArea object' do
    subject.geo_area = 'Geo area'
    is_expected.not_to be_valid
  end

  it '#state defaults to draft' do
    expect(subject.state).to eq 'draft'
  end

  it '#state uses fund.state' do
    subject.fund = Fund.new(state: 'stub')
    expect(subject.state).to eq 'stub'
  end

  it 'invalid #save returns false' do
    subject.name = nil
    expect(subject.save).to eq false
  end

  it 'valid #save creates draft Fund' do
    expect(subject.save).to eq true
    expect(Fund.last.state).to eq 'draft'
  end
end
