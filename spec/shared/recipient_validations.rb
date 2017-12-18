shared_examples 'recipient validations' do
  it 'required attributes' do
    %i[
      name
      country
      operating_for
      income_band
      employees
      volunteers
    ].each do |attribute|
      subject.send("#{attribute}=", '')
      expect(subject).not_to be_valid
    end
  end

  it 'in list' do
    %i[
      operating_for
      income_band
      employees
      volunteers
    ].each do |attribute|
      subject.send("#{attribute}=", -100)
      expect(subject).not_to be_valid
    end
  end

  it '#street_address' do
    [nil, 0, 4].each do |org_type|
      subject.org_type = org_type
      expect(subject).not_to be_valid
      expect(subject.errors.keys).to include(:street_address)
    end
  end
end
