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
      terms_agreed
    ].each do |attribute|
      invalid_attribute(:user, attribute)
    end
  end

  context '#terms_agreed and #terms_agreed=' do
    it 'truthy values set Time' do
      subject.terms_agreed = true
      [true, 'true', 1].each do |value|
        subject.terms_agreed = value
        expect(subject.terms_agreed).to eq(true)
        expect(subject.terms_agreed_time).to be_a(Time)
      end
    end

    it 'falsy values do not set Time' do
      [false, 0, nil].each do |value|
        subject.terms_agreed = value
        expect(subject.terms_agreed).to eq(false)
        expect(subject.terms_agreed_time).to eq(nil)
      end
    end
  end

  context 'on update' do
    before { subject.save! }

    it 'password fields required' do
      subject.valid?
      expect_error(:password, "can't be blank")
    end

    it 'password confirmation' do
      subject.password = '123123a'
      subject.valid?
      expect_error(:password_confirmation, "can't be blank")
    end

    it 'invalid #password' do
      subject.password = 'invaid_password'
      subject.valid?
      expect_error(:password, 'must contain at least one number')
    end

    it 'password length' do
      subject.password = 'sh0rt'
      subject.valid?
      expect_error(:password, 'is too short (minimum is 6 characters)')
    end
  end
end
