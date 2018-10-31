require 'rails_helper'

feature 'SignIn::Lookup' do
  include SignInHelper

  scenario 'redirects if User not found' do
    complete_sign_in_lookup('missing@user.com')
    expect(page).to have_link('create your first report')
  end

  context 'User without `password`' do
    let(:user) { create(:user) }

    scenario 'must set password' do
      complete_sign_in_lookup(user.email)
      expect(current_path).to eq(sign_in_reset_path)
    end
  end

  context 'User with `password`' do
    let(:user) { create(:user_with_password) }

    scenario 'redirects if signed in' do
      sign_in(user)
      visit sign_in_lookup_path
      expect(current_path).to eq(reports_path)
    end

    scenario 'can sign in' do
      complete_sign_in_lookup(user.email)
      expect(current_path).to eq(sign_in_auth_path)
    end
  end
end
