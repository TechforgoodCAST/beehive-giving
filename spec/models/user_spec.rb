require 'rails_helper'

describe User do
  subject { build(:user) }

  it('belongs to Organisation') do
    assoc(:organisation, :belongs_to, polymorphic: true, optional: true)
  end

  it('has many Feedbacks') { assoc(:feedbacks, :has_many) }

  it { is_expected.to be_valid }

  context '#agree_to_terms' do
    it 'invalid' do
      subject.agree_to_terms = false
      subject.valid?
      expect_error(:agree_to_terms, 'you must accept terms to continue')
    end
  end

  context '#email' do
    it 'existing' do
      subject.save!
      duplicate = subject.dup
      duplicate.valid?
      expect_error(:email, "please 'sign in' using the link above", duplicate)
    end

    it 'invalid' do
      subject.email = 'email[at]email.com'
      subject.valid?
      expect_error(:email, 'please enter a valid email')
    end

    it 'downcase' do
      subject.send(:email=, 'UPCASE@email.com')
      expect(subject.email).to eq('upcase@email.com')
    end

    it 'unique' do
      subject.save
      expect(build(:user, email: subject.email)).not_to be_valid
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

  context '#name' do
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

  context '#password' do
    it 'invalid' do
      subject.password = 'invaid_password'
      subject.valid?
      expect_error(:password, 'must include 6 characters with 1 number')
    end
  end
end
