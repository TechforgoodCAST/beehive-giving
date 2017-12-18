shared_examples 'setter to integer' do
  it 'returns integer' do
    attributes.each do |attribute|
      subject.send("#{attribute}=", 1)
      expect(subject.send(attribute)).to eq 1
    end
  end

  it 'valid string to integer' do
    attributes.each do |attribute|
      subject.send("#{attribute}=", '1')
      expect(subject.send(attribute)).to eq 1
    end
  end

  it 'invalid string to nil' do
    attributes.each do |attribute|
      subject.send("#{attribute}=", 'a')
      expect(subject.send(attribute)).to eq nil
    end
  end

  it 'empty string to nil' do
    attributes.each do |attribute|
      subject.send("#{attribute}=", '')
      expect(subject.send(attribute)).to eq nil
    end
  end
end
