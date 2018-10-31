require 'rails_helper'

describe SignIn::Auth do
  subject { described_class.new }

  it '#password required' do
    subject.valid?
    expect_error(:password, "can't be blank")
  end

  context '#authenticate(user)' do
    let(:user) { create(:user_with_password) }

    it 'invalid password' do
      subject.password = '1ncorrect'
      expect(subject.authenticate(user)).to eq(false)
      expect_error(:password, 'incorrect password')
    end

    it 'valid password' do
      subject.password = user.password
      expect(subject.authenticate(user)).to eq(true)
    end
  end
end
