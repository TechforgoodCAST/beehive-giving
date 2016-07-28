require 'rails_helper'
require_relative '../support/recipient_helper'

feature 'Account' do

  let(:recipient_helper) { RecipientHelper.new }

  context 'signed in' do
    before(:each) do
      seed_test_db
      @app = recipient_helper.
        create_recipient.
        with_user.
        registered_proposal.
        sign_in
      @data = @app.instances
    end

    scenario 'account link visible in navbar' do
      visit recommended_funders_path
      expect(page).to have_text 'My account'
    end

    scenario 'can navigate to account page and defaults to user page' do
      visit recommended_funders_path
      click_on 'My account'
      expect(current_path).to eq account_subscription_path(@data[:recipient])
    end

    # scenario 'can navigate to organisation page' do
    #   visit recommended_funders_path
    #   click_on 'My account'
    #   click_on 'Organisation'
    #   expect(current_path).to eq account_organisation_path(@data[:recipient])
    # end

    scenario 'can navigate to subscription page' do
      visit recommended_funders_path
      click_on 'My account'
      # click_on 'Subscription'
      expect(current_path).to eq account_subscription_path(@data[:recipient])
    end
  end
end
