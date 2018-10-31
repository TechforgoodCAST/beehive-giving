require 'rails_helper'

describe SignIn::Lookup do
  subject { described_class.new }

  it 'User not found' do
    subject.email = 'missing@user.org'
    subject.valid?
    msg = 'No account found, please ' \
          '<a href="/">create your first report</a>'.html_safe
    expect_error(:email, msg)
  end
end
