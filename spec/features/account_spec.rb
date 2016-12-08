require 'rails_helper'

feature 'Account' do
  context 'signed in' do
    before(:each) do
      @app.seed_test_db
          .create_recipient
          .with_user
          .create_registered_proposal
          .sign_in
      @db = @app.instances
    end

    scenario 'account link visible in navbar'
    #   visit recommended_funds_path
    #   expect(page).to have_text 'My account'
    # end

    scenario 'can navigate to account page and defaults to user page'
    #   visit recommended_funds_path
    #   click_on 'My account'
    #   expect(current_path).to eq account_subscription_path(@db[:recipient])
    # end

    # scenario 'can navigate to organisation page' do
    #   visit recommended_funds_path
    #   click_on 'My account'
    #   click_on 'Organisation'
    #   expect(current_path).to eq account_organisation_path(@db[:recipient])
    # end

    scenario 'can navigate to subscription page'
    #   visit recommended_funds_path
    #   click_on 'My account'
    #   # click_on 'Subscription'
    #   expect(current_path).to eq account_subscription_path(@db[:recipient])
    # end
  end
end
