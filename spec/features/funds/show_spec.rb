require 'rails_helper'

feature 'Show' do
  context 'signed in and registered' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(3, true, true)
          .create_recipient
          .with_user
          .create_registered_proposal
          .sign_in
      @db = @app.instances
      @fund = Fund.first
    end

    scenario 'fund with open_data shows chart' do
      visit fund_path(@fund)
      expect(page).to have_content 'position'
    end

    scenario 'fund without open_data hides chart' do
      @fund.open_data = false
      @fund.save!
      visit fund_path(@fund)
      expect(page).not_to have_content 'position'
    end
  end
end
