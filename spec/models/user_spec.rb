require 'rails_helper'

describe User do
  subject { build(:user) }

  it('has many Proposals') { assoc(:proposals, :has_many) }

  it('has many Recipients') { assoc(:recipients, :has_many) }

  it { is_expected.to be_valid }

  it '#auth_token set before create' do
    subject.save
    expect(subject.auth_token).not_to eq(nil)
    expect(subject.auth_token.size).to eq(22)
  end

  it 'capitalize #name and strip whitespace' do
    %i[first_name last_name].each do |col|
      subject.send("#{col}=", ' john ')
      expect(subject[col]).to eq('John')
    end
  end

  context '#email' do
    it 'downcase' do
      subject.send(:email=, 'UPCASE@email.com')
      expect(subject.email).to eq('upcase@email.com')
    end

    it 'invalid' do
      subject.email = 'email[at]email.com'
      subject.valid?
      expect_error(:email, 'please enter a valid email')
    end

    it 'unique' do
      subject.save!
      duplicate = subject.dup
      duplicate.valid?
      expect_error(:email, 'email already registered', duplicate)
    end
  end

  it '#full_name' do
    expect(subject.full_name).to eq('John Doe')
  end

  it 'invalid #marketing_consent' do
    subject.marketing_consent = nil
    subject.valid?
    expect_error(:marketing_consent, 'please select an option')
  end

  it 'invalid #password' do
    subject.password = 'invaid_password'
    subject.valid?
    expect_error(:password, 'must include 6 characters with 1 number')
  end

  it 'invalid #terms_agreed' do
    subject.terms_agreed = false
    subject.valid?
    expect_error(:terms_agreed, 'you must accept terms to continue')
  end

  it 'required attributes' do
    %i[
      email
      email_confirmation
      first_name
      last_name
      marketing_consent
      password
      terms_agreed
    ].each do |attribute|
      invalid_attribute(:user, attribute)
    end
  end

  context '#terms_agreed=' do
    it 'invalid arguments return nil' do
      [false, 1, 'true', nil].each do |value|
        subject.terms_agreed = value
        expect(subject.terms_agreed).to eq(nil)
      end
    end

    it 'TrueClass sets DateTime' do
      subject.terms_agreed = true
      expect(subject.terms_agreed).to be_a(Time)
    end
  end
end
