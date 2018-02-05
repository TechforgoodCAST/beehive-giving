require 'rails_helper'
require_relative '../support/eligibility_helper'

feature 'Apply' do
  let(:helper) { EligibilityHelper.new }

  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 7, open_data: true)
        .create_recipient
        .with_user
        .create_registered_proposal
        .sign_in
    @db = @app.instances
    @proposal = @db[:registered_proposal]
    @fund = @db[:funds].first
    visit root_path
    helper.visit_first_fund
          .complete_proposal
          .submit_proposal
          .answer_restrictions(@fund)
          .check_eligibility
          .answer_priorities(@fund)
          .check_suitability
    click_link 'Reveal'
    click_link 'Apply'
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
    click_link "Apply to #{@fund.title}"
    expect(@proposal.enquiries.count).to eq 1
    expect(@proposal.enquiries.last.approach_funder_count).to eq 1
    expect(current_url).to eq @fund.application_link

    visit apply_proposal_fund_path(@proposal, @fund)
    click_link "Apply to #{@fund.title}"
    expect(@proposal.enquiries.last.approach_funder_count).to eq 2
  end
end
