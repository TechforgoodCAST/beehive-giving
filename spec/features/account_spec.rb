require 'rails_helper'
require_relative '../support/account_helper'

feature 'Account' do
  let(:helper) { AccountHelper.new }

  context 'signed in' do
    before(:each) do
      @app.seed_test_db
          .create_recipient
          .with_user
          .create_registered_proposal
          .sign_in
      @db = @app.instances
      visit root_path
    end

    scenario 'account link visible in navbar' do
      expect(page).to have_text 'Dashboard'
    end

    scenario 'can navigate to account page and defaults to proposals dashboard' do
      click_on 'Dashboard', match: :first
      expect(current_path).to eq proposals_path
    end

    scenario 'can navigate to user profile page' do
      click_on 'Dashboard', match: :first
      click_on 'Account', match: :first
      expect(current_path).to eq account_path
    end

    scenario 'can update user profile' do
      click_on 'Dashboard', match: :first
      click_on 'Account', match: :first
      helper.update_user
      expect(page).to have_selector("input[value='Updates']")
      expect(page).to have_selector("input[value='User']")
    end

    scenario 'after user profile update must use updated details to sign in' do
      click_on 'Dashboard', match: :first
      click_on 'Account', match: :first
      helper.update_user
      @app.sign_out
      visit sign_in_path
      fill_in :email, with: 'updates.user@email.com'
      fill_in :password, with: 'newPa55word'
      click_button 'Sign in'
      expect(current_path)
        .to eq proposal_funds_path(@db[:registered_proposal])
    end

    scenario 'password update optional when updating user profile'

    scenario 'can navigate to organisation page' do
      click_on 'Dashboard', match: :first
      click_on 'Organisation'
      expect(current_path).to eq account_organisation_path(@db[:recipient])
    end

    scenario 'can update recipient' do
      click_on 'Dashboard', match: :first
      click_on 'Organisation'
      fill_in :recipient_name, with: 'A new name'
      click_button 'Update'
      expect(page).to have_selector("input[value='A new name']")
      expect(Recipient.last.name).to eq 'A new name'
    end

    scenario 'cannot submit invalid record' do
      click_on 'Dashboard', match: :first
      click_on 'Organisation'
      fill_in :recipient_name, with: ''
      click_button 'Update'
      expect(page).to have_text "can't be blank"
    end

    scenario 'can navigate to subscription page' do
      click_on 'Dashboard', match: :first
      click_on 'Subscription'
      expect(current_path).to eq account_subscription_path(@db[:recipient])
    end
  end

  context 'forgot password' do
    before(:each) do
      @app.seed_test_db
          .with_user
      @db = @app.instances
      @user = User.last
      visit root_path
    end

    scenario 'When I forget my password,
              I want to be able to reset it,
              so I access my account' do
      helper.request_reset
      expect(ActionMailer::Base.deliveries.last.subject)
        .to eq 'Reset your password - Beehive'
      expect(current_path).to eq sign_in_path
      helper.set_new_password
      expect(current_path).to eq sign_in_path
    end

    scenario 'When I click an expired reset password link,
              I want to see a message explaining the situation,
              so I understand what to do next' do
      helper.request_reset
      @user.update_attribute(:password_reset_sent_at, 2.hours.ago)
      visit edit_password_reset_path(@user)
      expect(current_path).to eq new_password_reset_path
    end

    scenario 'When I try to reset a nonexistant user,
              It should appear as if it worked but not trigger an email,
              so malicious users cannot determine account details' do
      ActionMailer::Base.deliveries = []
      helper.request_reset(email: 'random@email.com')
      expect(ActionMailer::Base.deliveries.size).to eq 0
      expect(current_path).to eq sign_in_path
    end

    scenario 'cannot visit password resets path if logged in' do
      @app.sign_in
      visit new_password_reset_path
      expect(current_path).not_to eq new_password_reset_path
    end

    scenario 'reset password page has has link to correct faq' do
      visit new_password_reset_path
      expect(find('a', text: 'here')[:href])
        .to eq faq_path(anchor: 'reset-password')
    end

    scenario 'set new password page has link to correct faq' do
      helper.request_reset
      expect(current_path).to eq sign_in_path
      visit edit_password_reset_path(User.last.password_reset_token)
      expect(find('a', text: 'here')[:href])
        .to eq faq_path(anchor: 'set-password')
    end
  end
end
