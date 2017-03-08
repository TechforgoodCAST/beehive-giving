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
      expect(page).to have_text 'Account'
    end

    scenario 'can navigate to account page and defaults to user page' do
      click_on 'Account', match: :first
      expect(current_path).to eq account_organisation_path(@db[:recipient])
    end

    scenario 'can navigate to organisation page' do
      click_on 'Account', match: :first
      click_on 'Organisation'
      expect(current_path).to eq account_organisation_path(@db[:recipient])
    end

    scenario 'can update recipient' do
      click_on 'Account', match: :first
      fill_in :recipient_name, with: 'A new name'
      click_button 'Update'
      expect(page).to have_selector("input[value='A new name']")
      expect(Recipient.last.name).to eq 'A new name'
    end

    scenario 'cannot submit invalid record' do
      click_on 'Account', match: :first
      fill_in :recipient_name, with: ''
      click_button 'Update'
      expect(page).to have_text "can't be blank"
    end

    scenario 'can navigate to subscription page'
    #   visit recommended_funds_path
    #   click_on 'My account'
    #   # click_on 'Subscription'
    #   expect(current_path).to eq account_subscription_path(@db[:recipient])
    # end
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
      helper.set_new_password
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
      expect(find('.faq-link')[:href]).to eq faq_path(anchor: 'reset-password')
    end

    scenario 'set new password page has link to correct faq' do
      helper.request_reset
      expect(current_path).to eq sign_in_path
      visit edit_password_reset_path(User.last.password_reset_token)
      expect(find('.faq-link')[:href]).to eq faq_path(anchor: 'set-password')
    end
  end
end
