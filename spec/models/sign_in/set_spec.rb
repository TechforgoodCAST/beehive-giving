require 'rails_helper'

describe SignIn::Set do
  subject { described_class.new }

  context '#password' do
    it 'present' do
      subject.valid?
      expect_error(:password, "can't be blank")
    end

    it 'format' do
      subject.password = 'wrong format'
      subject.valid?
      expect_error(:password, 'must contain at least one number')
    end

    it 'length' do
      subject.password = 'sh0rt'
      subject.valid?
      expect_error(:password, 'is too short (minimum is 6 characters)')
    end
  end

  context '#password_confirmation' do
    it 'present' do
      subject.valid?
      expect_error(:password_confirmation, "can't be blank")
    end

    it 'matches #password' do
      subject.password = '123123a'
      subject.password_confirmation = 'different'
      subject.valid?
      expect_error(:password_confirmation, "doesn't match Password")
    end
  end

  context '#save' do
    let(:user) { create(:user) }

    before { subject.user = user }

    it 'invalid' do
      expect(subject.save).to eq(false)
    end

    it 'valid' do
      expect(user.password_digest).to eq(nil)

      complete_password(subject)
      subject.save

      expect(subject.save).to eq(true)
      expect(user.password_digest).not_to eq(nil)
    end

    context 'marketing_consent' do
      before do
        user.update_column(:marketing_consent, nil)
        subject.user = user
      end

      it 'not changed' do
        expect(subject.user.marketing_consent).to eq(nil)
        complete_password(subject)
        subject.save
        expect(subject.user.marketing_consent).to eq(nil)
      end

      it 'changed' do
        expect(subject.user.marketing_consent).to eq(nil)
        complete_password(subject)
        subject.marketing_consent = true
        subject.save
        expect(subject.user.marketing_consent).to eq(true)
      end
    end

    context 'terms_agreed' do
      before do
        user.update_column(:terms_agreed, nil)
        subject.user = user
      end

      it 'not changed' do
        expect(subject.user.terms_agreed).to eq(false)
        complete_password(subject)
        subject.save
        expect(subject.user.terms_agreed).to eq(false)
      end

      it 'changed' do
        expect(subject.user.terms_agreed).to eq(false)
        complete_password(subject)
        subject.terms_agreed = true
        subject.save
        expect(subject.user.terms_agreed).to eq(true)
      end

      it 'terms version set if terms agreed' do
        expect(subject.user.terms_version).to eq(nil)
        complete_password(subject)
        subject.terms_agreed = true
        subject.save
        expect(subject.user.terms_version).to be_a(Date)
      end
    end
  end

  def complete_password(subject, password = '123123a')
    subject.password = password
    subject.password_confirmation = password
  end
end
