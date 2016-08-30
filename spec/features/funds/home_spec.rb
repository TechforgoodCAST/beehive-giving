require 'rails_helper'

feature 'Home' do
  context 'signed in' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(num: 3, open_data: true)
          .create_recipient
          .with_user
          .create_registered_proposal
          .sign_in
      @db = @app.instances
    end

    scenario 'recommended funds shown' do
      visit funds_home_path
      expect(Fund.count).to eq 3
      expect(page).to have_css '.funder', count: 3
    end
  end
end
