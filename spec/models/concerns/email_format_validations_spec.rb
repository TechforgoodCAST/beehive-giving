require 'rails_helper'

describe EmailFormatValidations do
  subject do
    class Email
      include ActiveModel::Model
      include EmailFormatValidations
      attr_accessor :email
    end
    Email.new
  end

  context '#email' do
    it 'present' do
      subject.email = nil
      subject.valid?
      expect_error(:email, "can't be blank")
    end

    it 'format' do
      subject.email = 'email[at]email.com'
      subject.valid?
      expect_error(:email, 'please enter a valid email')
    end
  end
end
