require 'rails_helper'
require_relative '../support/eligibility_helper'

feature 'Apply' do

  let(:helper) { EligibilityHelper.new }

  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 7, open_data: true)
        .tag_funds
        .create_recipient
        .with_user
        .create_registered_proposal
        .sign_in
    @db = @app.instances
    @proposal = @db[:registered_proposal]
    @fund = @db[:funds].last
    visit root_path
    helper.visit_first_fund
        .complete_proposal
        .submit_proposal
        .answer
        .check_eligibility
    within '.card' do
      click_link 'Apply'
    end
  end

  scenario 'When I look to apply to an eligible fund,
            I want to be presented with application specific guidance,
            so I can decide whether to continue with an appliation' do
    expect(page).to have_text 'Key criteria'
  end

  scenario 'When I click Apply for funding,
            I want to be redirected to the funds application page,
            so I can apply for funding directly' do
    expect(@proposal.enquiries.count).to eq 0
    click_link "Apply to #{@fund.name}"
    expect(@proposal.enquiries.count).to eq 1
    expect(@proposal.enquiries.last.approach_funder_count).to eq 1
    expect(current_url).to eq "#{@fund.application_link}/welcome" # TODO:

    visit fund_apply_path(@fund)
    click_link "Apply to #{@fund.name}"
    expect(@proposal.enquiries.last.approach_funder_count).to eq 2
  end

end
