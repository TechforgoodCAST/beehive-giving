require 'rails_helper'

describe User do
  subject { build(:user) }

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

  context '#funder?' do
    it 'fundraiser' do
      expect(subject.funder?).to eq(false)
    end

    it 'funder' do
      subject.organisation_type = 'Funder'
      expect(subject.funder?).to eq(true)
    end
  end

  context '#legacy' do
    it('incomplete') do
      expect(subject.legacy?).to eq(true)
    end

    it('registered') do
      subject.organisation = build(:recipient, proposals: [build(:proposal)])
      expect(subject.legacy?).to eq(false)
    end
  end
end
