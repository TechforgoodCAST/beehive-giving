require 'rails_helper'

feature 'Browse' do

  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 3, open_data: true)
        .create_recipient
        .with_user
        .create_registered_proposal
    @db = @app.instances
    visit sign_in_path
  end

  scenario 'When I sign in,
            I want to see my recommended fund,
            so I can see my results' do
    fill_in :email, with: @db[:user].user_email
    fill_in :password, with: @db[:user].password
    click_button 'Sign in'
    expect(current_path).to eq recommended_funds_path
  end

  context 'signed in' do
    before(:each) do
      @fund = Fund.first
      @app.sign_in
      visit root_path
    end

    scenario "When I find a fund I'm interested in,
              I want to view further details,
              so I can decide if I want to apply" do
      click_link @fund.name
      expect(current_path).to eq fund_path(@fund)
    end

    # TODO: thumbnail link
    # TODO: card more info link
    # TODO: insight more info link
  end

end
