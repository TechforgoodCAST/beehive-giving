require 'rails_helper'
require 'shared/reg_no_validations'
require 'shared/setter_to_integer'

describe User do
  subject { build(:user) }

  include_examples 'reg no validations'

  include_examples 'setter to integer' do
    let(:attributes) { [:org_type] }
  end

  it('belongs to Organisation') do
    assoc(:organisation, :belongs_to, polymorphic: true, optional: true)
  end

  it('has many Feedbacks') { assoc(:feedbacks, :has_many) }

  it { is_expected.to be_valid }

  context 'email' do
    it 'unique' do
      subject.save
      expect(build(:user, email: subject.email)).not_to be_valid
    end

    it 'downcase' do
      subject.send(:email=, 'UPCASE@email.com')
      expect(subject.email).to eq('upcase@email.com')
    end
  end

  context 'name' do
    it 'invalid' do
      %i[first_name last_name].each do |col|
        subject.send("#{col}=", ':Name!')
        expect(subject).not_to be_valid
      end
    end

    it 'capitalize name and strip whitespace' do
      %i[first_name last_name].each do |col|
        subject.send("#{col}=", ' john ')
        expect(subject[col]).to eq('John')
      end
    end
  end

  it 'org_type converted to integer' do
    subject.send(:org_type=, '0')
    expect(subject.org_type).to eq(0)
  end
end
