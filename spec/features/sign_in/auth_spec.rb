require 'rails_helper'

feature 'SignIn::Auth' do
  include SignInHelper

  scenario 'redirects if User not found' do
    visit sign_in_auth_path
    expect(current_path).to eq(sign_in_lookup_path)
  end

  context 'User without `password`' do
    let(:user) { create(:user) }

    scenario 'redirected' do
      complete_sign_in_lookup(user.email)
      expect(current_path).to eq(sign_in_reset_path)
    end
  end

  context 'User with `password`' do
    let(:user) { create(:user_with_password) }

    scenario 'redirects if signed in' do
      sign_in(user)
      visit sign_in_auth_path
      expect(current_path).to eq(reports_path)
    end

    scenario 'valid can sign in' do
      sign_in(user)
      expect(current_path).to eq(reports_path)
    end

    scenario 'invalid cannot sign in' do
      sign_in(user, password: '1ncorrect')
      expect(page).to have_text('incorrect password')
    end

    scenario 'forgets password' do
      complete_sign_in_lookup(user.email)
      click_link('Forgot password?')
      expect(current_path).to eq(sign_in_reset_path)
    end

    context do
      scenario 'can sign out' do
        sign_in(user)
        visit sign_out_path
        expect(current_path).to eq(root_path)

        expect(page.driver.request.cookies).not_to have_key('auth_token')
      end
    end

    scenario 'metrics updated when signing in' do
      expect(user.sign_in_count).to eq(0)
      sign_in(user)
      user.reload
      expect(user.sign_in_count).to eq(1)
    end

    scenario 'returned to original url after signing in' do
      proposal = create(:proposal, private: Time.zone.now)
      visit report_path(proposal)
      expect(current_path).to eq(sign_in_lookup_path)

      sign_in(user)
      expect(current_path).to eq(report_path(proposal))
    end
  end
end
