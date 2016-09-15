require 'rails_helper'

feature 'Eligibility' do

  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 7, open_data: true)
        .tag_funds
        .create_recipient
        .with_user
        .create_registered_proposal
        .sign_in
    @db = @app.instances
    @fund = Fund.last
    visit root_path
  end

  scenario 'When I check eligibility for a recommended fund,
            I want to see a list of restrictions,
            so I can check to see if any apply' do
    click_link 'Check eligibility', match: :first
    expect(current_path).to eq fund_eligibility_path(@fund)
    expect(page).to have_css '.restriction', count: 2
  end

  scenario 'When I have outstanding eligibility questions to answer,
            I want to be able to answer them,
            so I can check my eligibility'

  scenario "When I run a check and I'm eligible,
            I want to see a link to apply for funding,
            so I can see further details about applying"
            # funder card

  scenario "When I run a check and I'm ineligible,
            I want to see which options did not meet the criteria,
            so I can correct them if neccesary"

  scenario "When I'm ineligible and try to access application details,
            I want to be told why I can't access them,
            so I understand what to do next"

  scenario 'When I try check eligiblity but have reached the max free limit,
            I want to be able to upgrade,
            so I can continue to check eligibilities'

  # TODO: running a check iterates one free usage

end
