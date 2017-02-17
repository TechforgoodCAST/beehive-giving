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

  scenario 'invalid recipient restriction affects all proposals'

  scenario 'When I have previous eligibility checks,
            I want to see a message explaining new changes,
            so I understand what happend to my previous work' do
    def assert(present: true)
      copy = 'Last time you used Beehive you conducted 1 eligibility check'
      [
        recommended_funds_path,
        eligible_funds_path,
        ineligible_funds_path
      ].each do |path|
        visit path
        if present
          expect(page).to have_text copy
        else
          expect(page).not_to have_text copy
        end
      end
    end

    assert(present: false)

    RecipientFunderAccess.create(
      recipient: @db[:recipient], funder_id: Funder.first.id
    )
    Recipient.joins(:recipient_funder_accesses)
             .group(:recipient_id).count.each do |k, v|
      Recipient.find(k).update_column(:funds_checked, v)
    end

    assert
  end

  scenario "When I check eligibility for the first time and need to update my
            proposal, I want to understand why I need to do it,
            so I feel I'm using my time in the best way" do
    helper.visit_first_fund
    expect(page).to have_text 'Complete your funding proposal to gain access ' \
                              'to eligibility checking features on Beehive.'
  end

  scenario "When I'm try to access application details before checking
            eligiblity, I want to be told why I can't access them,
            so I understand what to do next" do
    visit fund_apply_path(@fund)
    expect(page).to have_text 'Complete your funding proposal to gain access ' \
                              'to eligibility checking features on Beehive.'

    helper.complete_proposal.submit_proposal
    visit fund_apply_path(@fund)
    expect(current_path).to eq fund_eligibility_path(@fund)
  end

  context 'complete proposal' do
    before(:each) do
      helper.visit_first_fund.complete_proposal.submit_proposal
    end

    scenario 'When I select a restriction that is inverted,
              I want it to be recorded as eligible,
              so I recieve an accurate check' do
      @fund.restrictions.first.update(invert: true)
      helper.visit_first_fund
      within 'label[for=check_recipient_eligibilities_attributes_1_eligible' \
             '_true]' do
        expect(page).to have_text 'Yes'
      end
      helper.answer_restrictions.check_eligibility
      expect(page).to have_text 'You are eligible'
    end

    scenario "When I only answer recipient restrictions,
              I want them to be saved,
              so that I don't have to resubmit them" do
      helper.visit_first_fund
            .answer_recipient_restrictions
            .check_eligibility
            .visit_first_fund
      expect(page).to have_css '.radio_buttons[checked=checked]', count: 2
    end

    scenario 'When I visit a fund without recipient restrictions,
              I want to only see proposal restrictions,
              so I avoid answering unnecessary questions' do
      helper.remove_restrictions(@fund, 'Organisation')
            .visit_first_fund
            .answer_proposal_restrictions
            .check_eligibility
      expect(page).not_to have_css '.recipient_restriction'
      expect(page).to have_text 'You are eligible'
    end

    scenario 'When I only submit answers to proposal restrictions,
              I want the check to be invalid,
              so I avoid accidently checking a fund' do
      helper.visit_first_fund
            .answer_proposal_restrictions
            .check_eligibility
      expect(page).to have_css '.field_with_errors', count: 2
    end

    scenario 'When I only submit answers to recipient restrictions,
              I want the check to be invalid,
              so I avoid accidently checking a fund' do
      helper.visit_first_fund
            .answer_recipient_restrictions
            .check_eligibility
      expect(page).to have_css '.field_with_errors', count: 3
    end

    scenario 'When I visit a fund without proposal restrictions,
              I want to only see recipient restrictions,
              so I avoid answering unnecessary questions' do
      helper.remove_restrictions(@fund, 'Proposal')
            .visit_first_fund
            .answer_recipient_restrictions
            .check_eligibility
      expect(page).not_to have_css '.proposal_restriction'
      expect(page).to have_text 'You are eligible'
    end

    scenario 'When I try check eligibility for a recommended fund,
              I want to see a list of all restrictions,
              so I can check to see if any apply' do
      expect(current_path).to eq fund_eligibility_path(@fund)
      expect(page).to have_css '.restriction', count: 5
      expect(page).to have_css '.recipient_restriction', count: 2
      expect(page).to have_css '.proposal_restriction', count: 3
    end

    scenario "When I run a check and I'm eligible,
              I want to see a link to apply for funding,
              so I can see further details about applying" do
      helper.answer_restrictions.check_eligibility
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
      helper.answer_recipient_restrictions
            .answer_proposal_restrictions(eligible: false)
            .check_eligibility
      expect(page).to have_text 'You are ineligible, and did not meet 3 of ' \
                                'the criteria below.'
      expect(page).to have_text 'You did not meet this criteria', count: 3

      click_link 'Why ineligible?'
      expect(current_path).to eq fund_eligibility_path(@fund)

      helper.answer_restrictions.update
      expect(page).to have_text 'Apply'
      expect(page).to have_text 'Apply for funding'

      # No feedback for unlocked funds
      click_link 'Funding'
      helper.visit_first_fund.check_eligibility(remaining: 2)
      visit fund_eligibility_path(@fund)
      expect(current_path).to eq fund_eligibility_path(@fund)
    end

    scenario "When I check a fund with shared restrictions,
              I want associated funds to be checked, so
              I don't waste time checking funds with the same restrictions" do
      helper.answer_restrictions.check_eligibility
      expect(@db[:registered_proposal].reload.eligibility.count).to eq 4
    end

    scenario "When I've answered some eligibility questions in another fund,
              I want previously answered questions to be prefilled,
              so I don't waste my time answering the same question twice" do
      helper.answer_recipient_restrictions
            .answer_proposal_restrictions(eligible: false)
            .check_eligibility
      visit fund_eligibility_path(Fund.second)
      helper.check_eligibility(remaining: 2)
      expect(page).to have_text 'please select from the list', count: 2
    end

    scenario "When I'm ineligible and try to access application details,
              I want to be told why I can't access them,
              so I understand what to do next" do
      helper.answer_recipient_restrictions
            .answer_proposal_restrictions(eligible: false)
            .check_eligibility
      visit fund_apply_path(@fund)
      expect(current_path).to eq fund_eligibility_path(@fund)
    end

    scenario 'When I try check eligiblity but have reached the max free limit,
              I want to be able to upgrade,
              so I can continue to check eligibilities' do
      # TODO: refactor
      Fund.second.restrictions << create(:restriction)
      Fund.second.instance_eval { set_restriction_ids }
      Fund.second.save
      @fund.restrictions << create(:restriction)
      @fund.instance_eval { set_restriction_ids }
      @fund.save

      # check 1
      helper.answer_restrictions.check_eligibility

      # check 2
      click_link 'Funding'
      # puts page.body
      helper.visit_first_fund
            .answer_recipient_restrictions
            .answer_proposal_restrictions(n: 4)
            .check_eligibility(remaining: 2)

      expect(@db[:recipient].reload.funds_checked).to eq 2
      # expect(@db[:registered_proposal].reload.eligibility).to eq 2

      # check 3
      click_link 'Funding'
      helper.visit_first_fund
      expect(current_path).to eq new_feedback_path
      helper.complete_feedback.submit_feedback
      helper.answer_restrictions.check_eligibility(remaining: 1)

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
          .visit_first_fund.answer_restrictions.check_eligibility
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
        helper.visit_first_fund
              .complete_proposal
              .submit_proposal
              .visit_first_fund
              .answer_recipient_restrictions
              .answer_proposal_restrictions(eligible: false)
              .check_eligibility
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
