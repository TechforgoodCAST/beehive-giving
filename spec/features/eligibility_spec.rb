require 'rails_helper'
require_relative '../support/eligibility_helper'

feature 'Eligibility' do

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
    @fund = Fund.last
    visit root_path
  end

  scenario "When I check eligibility for the first time and need to update my proposal,
            I want to understand why I need to do it,
            so I feel I'm using my time in the best way" do
    helper.visit_first_fund
    expect(page).to have_text 'Complete your funding proposal to gain access to eligibility checking features on Beehive.'
  end

  scenario "When I'm try to access application details before checking eligiblity,
            I want to be told why I can't access them,
            so I understand what to do next" do
    visit fund_apply_path(@fund)
    expect(page).to have_text 'Complete your funding proposal to gain access to eligibility checking features on Beehive.'

    helper.complete_proposal.submit_proposal
    visit fund_apply_path(@fund)
    expect(current_path).to eq fund_eligibility_path(@fund)
  end

  context 'complete proposal' do
    before(:each) do
      helper.visit_first_fund.complete_proposal.submit_proposal
    end

    scenario 'When I try check eligibility for a recommended fund,
              I want to see a list of all restrictions,
              so I can check to see if any apply' do
      expect(current_path).to eq fund_eligibility_path(@fund)
      expect(page).to have_css '.restriction', count: 2
    end

    scenario "When I run a check and I'm eligible,
              I want to see a link to apply for funding,
              so I can see further details about applying" do
      helper.answer.check_eligibility
      expect(page).to have_text 'Update'

      within '.card' do
        click_link 'Apply'
      end
      expect(current_path).to eq fund_apply_path(@fund)

      visit fund_eligibility_path(@fund)
      click_link 'Apply for funding'
      expect(current_path).to eq fund_apply_path(@fund)
    end

    scenario "When I run a check and I'm ineligible,
              I want to see which options did not meet the criteria,
              so I can correct them if neccesary" do
      helper.answer(eligible: false).check_eligibility
      expect(page).to have_text 'You are ineligible, and did not meet 2 of the criteria below.'
      expect(page).to have_text 'You did not meet this criteria', count: 2

      click_link 'Why ineligible?'
      expect(current_path).to eq fund_eligibility_path(@fund)

      helper.answer.update
      expect(page).to have_text 'Apply'
      expect(page).to have_text 'Apply for funding'

      # No feedback for unlocked funds
      click_link 'Funding'
      helper.visit_first_fund.check_eligibility(remaining: 2)
      visit fund_eligibility_path(@fund)
      expect(current_path).to eq fund_eligibility_path(@fund)
    end

    scenario "When I've answered some eligibility questions in another fund,
              I want previously answered questions to be prefilled,
              so I don't waste my time answering the same question twice" do
      helper.answer(eligible: false).check_eligibility

      fund = Fund.first
      fund.restriction_ids = fund.restriction_ids << create(:restriction).id
      fund.save!
      expect(fund.restrictions.count).to eq 3

      visit fund_eligibility_path(fund)
      helper.check_eligibility(remaining: 2)
      expect(page).to have_text 'please select from the list', count: 1
    end

    scenario "When I'm ineligible and try to access application details,
              I want to be told why I can't access them,
              so I understand what to do next" do
      helper.answer(eligible: false).check_eligibility
      visit fund_apply_path(@fund)
      expect(current_path).to eq fund_eligibility_path(@fund)
    end

    scenario 'When I try check eligiblity but have reached the max free limit,
              I want to be able to upgrade,
              so I can continue to check eligibilities' do
      helper.answer.check_eligibility

      click_link 'Funding'
      helper.visit_first_fund.check_eligibility(remaining: 2)

      click_link 'Funding'
      helper.visit_first_fund
      expect(current_path).to eq new_feedback_path
      helper.complete_feedback.submit_feedback
      helper.check_eligibility(remaining: 1)

      click_link 'Funding'
      helper.visit_first_fund
      # TODO: subscription
      expect(page).to have_text 'Coming soon'
      fill_in :feedback_price, with: 50
      click_button 'Save feedback'
      expect(current_path).to eq recommended_funds_path
    end
  end

end
