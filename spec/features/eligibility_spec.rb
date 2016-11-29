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
      expect(page).to have_css '.restriction', count: 3
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
      expect(page).to have_text 'You are ineligible, and did not meet 3 of the criteria below.'
      expect(page).to have_text 'You did not meet this criteria', count: 3

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

    scenario "When I check a fund with shared restrictions,
              I want associated funds to be checked,
              so I don't waste time checking funds with the same restrictions" do
      helper.answer.check_eligibility
      expect(@db[:recipient].unlocked_funds.count).to eq 4
    end

    scenario "When I've answered some eligibility questions in another fund,
              I want previously answered questions to be prefilled,
              so I don't waste my time answering the same question twice" do
      helper.answer(eligible: false).check_eligibility
      visit fund_eligibility_path(Fund.second)
      helper.check_eligibility(remaining: 2)
      expect(page).to have_text 'please select from the list', count: 2
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
      Fund.second.restrictions << create(:restriction)
      @fund.restrictions << create(:restriction)

      # check 1
      helper.answer.check_eligibility

      # check 2
      click_link 'Funding'
      helper.visit_first_fund.answer(n: 4).check_eligibility(remaining: 2)

      # check 3
      click_link 'Funding'
      helper.visit_first_fund
      expect(current_path).to eq new_feedback_path
      helper.complete_feedback.submit_feedback
      helper.answer.check_eligibility(remaining: 1)

      # checked funds shouldn't show 'Coming soon'
      click_link 'Funding'
      visit fund_eligibility_path(Fund.first)
      expect(current_path).to eq fund_eligibility_path(Fund.first)

      # unchecked funds show 'Coming soon'
      click_link 'Funding'
      helper.visit_first_fund
      # # TODO: subscription
      expect(page).to have_text 'Coming soon'
      fill_in :feedback_price, with: 50
      click_button 'Save feedback'
      expect(current_path).to eq recommended_funds_path
    end
  end

  context 'eligible_funds_path' do
    scenario 'When I navigate to my eligible funds,
              I want to see a list of eligible funds,
              so I can apply for to them' do
      click_link 'Eligible'
      expect(page).to have_text "You don't have any eligible funds"
    end

    context 'eligible fund' do
      before(:each) do
        helper
          .visit_first_fund.complete_proposal.submit_proposal
          .visit_first_fund.answer.check_eligibility
          visit root_path
      end

      scenario "When I'm browsing funds,
                I want to see how many eligible funds I have,
                so I can decide to view them" do
        expect(page).to have_text 'Eligible (4)'
      end

      scenario "When I click on an 'Eligible' tag,
                I want to see a list of eligible funds,
                so I can compare them" do
        within '.insights', match: :first do
          click_link 'Eligible'
          expect(current_path).to eq eligible_funds_path
        end
      end
    end
  end

  context 'ineligible_funds_path' do
    scenario 'When I navigate to my ineligible funds,
              I want to see a list of ineligible funds,
              so I can apply for to them' do
      click_link 'Ineligible'
      expect(page).to have_text "Awesome, you're not ineligible for any funds!"
    end

    context 'ineligible fund' do
      before(:each) do
        helper
          .visit_first_fund.complete_proposal.submit_proposal
          .visit_first_fund.answer(eligible: false).check_eligibility
          visit root_path
      end

      scenario "When I'm browsing funds,
                I want to see how many ineligible funds I have,
                so I can decide to view them" do
        expect(page).to have_text 'Ineligible (4)'
      end

      scenario "When I click on an 'Ineligible' tag,
                I want to see a list of ineligible funds,
                so I can compare them" do
        visit ineligible_funds_path
        within '.insights', match: :first do
          click_link 'Ineligible'
          expect(current_path).to eq ineligible_funds_path
        end
      end
    end
  end

end
