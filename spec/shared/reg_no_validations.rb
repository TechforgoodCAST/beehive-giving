shared_examples 'reg no validations' do
  context 'charity_number' do
    before(:each) do
      subject.charity_number = nil
    end

    it 'required if org_type 1' do
      subject.org_type = 1
      is_expected.not_to be_valid
    end

    it 'required if org_type 3' do
      subject.org_type = 3
      is_expected.not_to be_valid
    end
  end

  context 'company_number' do
    before(:each) do
      subject.company_number = nil
    end

    it 'required if org_type 2' do
      subject.org_type = 2
      is_expected.not_to be_valid
    end

    it 'required if org_type 3' do
      subject.org_type = 3
      is_expected.not_to be_valid
    end

    it 'required if org_type 5' do
      subject.org_type = 5
      is_expected.not_to be_valid
    end
  end
end
