require 'rails_helper'

feature 'SignIn::Reset' do
  include SignInHelper

  scenario 'redirects if User not found' do
    visit sign_in_reset_path
    expect(current_path).to eq(sign_in_lookup_path)
  end

  context 'User without `password`' do
    let(:emails) { ActionMailer::Base.deliveries }
    let(:user) { create(:user) }

    scenario 'sends instructions' do
      ActionMailer::Base.deliveries = []
      complete_sign_in_lookup(user.email)
      visit sign_in_reset_path

      expect(emails.size).to eq(1)
      expect(emails.last.subject).to eq('Reset your password [Beehive]')
    end
  end

  context 'User with `password`' do
    let(:user) { create(:user_with_password) }

    scenario 'redirects if signed in' do
      sign_in(user)
      visit sign_in_reset_path
      expect(current_path).to eq(reports_path)
    end
  end
end
