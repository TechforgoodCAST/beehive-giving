shared_examples 'org_type validations' do
  context '#org_type' do
    it 'required' do
      subject.org_type = nil
      is_expected.not_to be_valid
    end

    it 'in list' do
      subject.org_type = -1
      is_expected.not_to be_valid
    end
  end
end
