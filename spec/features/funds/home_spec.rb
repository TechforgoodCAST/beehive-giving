require 'rails_helper'

feature 'Home' do

  let(:test_helper) { TestHelper.new }

  context 'signed in' do
    before(:each) do
      @app = test_helper.
               seed_test_db.
               setup_funds(3, true).
               create_recipient.
               with_user.
               create_registered_proposal.
               sign_in
      @db = @app.instances
    end

    scenario 'recommended funds shown' do
      visit funds_home_path
      expect(Fund.count).to eq 3
      expect(page).to have_css '.funder', count: 3
    end

  end
end
