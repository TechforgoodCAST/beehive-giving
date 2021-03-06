require 'rails_helper'

feature 'SignIn::Set' do
  include SignInHelper

  scenario 'redirects if User not found' do
    visit sign_in_set_path('old-token')
    expect(current_path).to eq(sign_in_lookup_path)
    expect(page).to have_text('Password reset expired')
  end

  context 'User without `password`' do
    let(:user) { create(:user) }

    scenario 'can set password' do
      complete_sign_in_lookup(user.email)
      visit_sign_in_reset_path_from_email

      password = '123123a'
      fill_in(:sign_in_set_password, with: password)
      fill_in(:sign_in_set_password_confirmation, with: password)
      click_button('Continue')

      expect(current_path).to eq(reports_path)
    end

    scenario 'token valid for one hour' do
      complete_sign_in_lookup(user.email)
      user.update_column(:password_reset_sent_at, 1.day.ago)
      visit_sign_in_reset_path_from_email

      expect(current_path).to eq(sign_in_lookup_path)
      expect(page).to have_text('Password reset expired')
    end
  end

  context 'User with `password`' do
    let(:user) { create(:user_with_password) }

    scenario 'redirects if signed in' do
      sign_in(user)
      visit sign_in_set_path('old-token')
      expect(current_path).to eq(reports_path)
    end

    scenario 'can sign in' do
      complete_sign_in_lookup(user.email)
      expect(current_path).to eq(sign_in_auth_path)
    end
  end

  context 'legacy support' do
    before do
      complete_sign_in_lookup(user.email)
      visit_sign_in_reset_path_from_email
      password = '123123a'
      fill_in(:sign_in_set_password, with: password)
      fill_in(:sign_in_set_password_confirmation, with: password)
    end

    context 'user without terms agreed' do
      let(:user) do
        user = create(:user)
        user.update_column(:terms_agreed, nil)
        user
      end

      scenario 'can agree to terms' do
        expect(page).to have_text('I accept the terms of service')
        check(:sign_in_set_terms_agreed)
        click_button('Continue')
        expect(current_path).to eq(reports_path)
      end
    end

    context 'user without marketing consent' do
      let(:user) do
        user = create(:user)
        user.update_column(:marketing_consent, nil)
        user
      end

      scenario 'can set preferences' do
        expect(page).to have_text('Email me with occasional updates')
        choose('Yes')
        click_button('Continue')
        expect(current_path).to eq(reports_path)
      end
    end
  end

  def visit_sign_in_reset_path_from_email
    last_email = ActionMailer::Base.deliveries.last
    reset_path = last_email.body.match(/(?<path>\/sign-in\/set\/.+?)">/)[:path]
    visit current_host + reset_path
  end
end
