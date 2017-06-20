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
    @proposal = @db[:registered_proposal]
    visit root_path
  end

  scenario 'invalid recipient restriction affects all proposals'

  scenario 'When I have previous eligibility checks,
            I want to see a message explaining new changes,
            so I understand what happend to my previous work' do
    def assert(present: true)
      copy = 'Last time you used Beehive you conducted 1 eligibility check'
      [
        recommended_proposal_funds_path(@proposal),
        eligible_proposal_funds_path(@proposal),
        ineligible_proposal_funds_path(@proposal)
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
    expect(page).to have_text 'Complete your funding proposal to access '
  end

  scenario "When I'm try to access application details before checking
            eligiblity, I want to be told why I can't access them,
            so I understand what to do next" do
    visit apply_proposal_fund_path(@proposal, @fund)
    expect(page).to have_text 'Complete your funding proposal to access '

    helper.complete_proposal.submit_proposal
    visit apply_proposal_fund_path(@proposal, @fund)
    expect(current_path).to eq eligibility_proposal_fund_path(@proposal, @fund)
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
      within 'label[for=check_recipient_eligibilities_attributes_0_eligible' \
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
      expect(current_path)
        .to eq eligibility_proposal_fund_path(@proposal, @fund)
      expect(page).to have_css '.restriction', count: 5
      expect(page).to have_css '.recipient_restriction', count: 2
      expect(page).to have_css '.proposal_restriction', count: 3
    end

    scenario "When I run a check and I'm eligible,
              I want to see a link to apply for funding,
              so I can see further details about applying" do
      helper.answer_restrictions.check_eligibility
      expect(page).to have_text 'Update'

      within('.card') { click_link 'Apply' }
      expect(current_path).to eq apply_proposal_fund_path(@proposal, @fund)

      visit eligibility_proposal_fund_path(@proposal, @fund)
      click_link 'Apply for funding'
      expect(current_path).to eq apply_proposal_fund_path(@proposal, @fund)

      visit proposal_fund_path(@proposal, @fund)
      within('.card') { click_link 'Apply' }
      expect(current_path).to eq apply_proposal_fund_path(@proposal, @fund)
    end

    scenario "When I run a check and I'm ineligible,
              I want to see which options did not meet the criteria,
              so I can correct them if neccesary" do
      helper.answer_recipient_restrictions
            .answer_proposal_restrictions(eligible: false)
            .check_eligibility
      expect(page).to have_text 'You are ineligible, and do not meet 3 of ' \
                                'the criteria below.'
      expect(page).to have_text 'You did not meet this criteria', count: 3

      click_link 'Why ineligible?'
      expect(current_path)
        .to eq eligibility_proposal_fund_path(@proposal, @fund)

      helper.answer_restrictions.update
      expect(page).to have_text 'Apply'
      expect(page).to have_text 'Apply for funding'

      # TODO: No feedback for unlocked funds
      # TODO: eligibilities_controller does not prevent navigation
      # e.g. visit eligibility_proposal_fund_path(@proposal, @fund)
    end

    scenario "When I check a fund with shared restrictions,
              I want associated funds to be checked, so
              I don't waste time checking funds with the same restrictions" do
      helper.answer_restrictions.check_eligibility
      expect(Proposal.last.eligibility.all_values_for('quiz').length).to eq 4
    end

    scenario "When I've answered some eligibility questions in another fund,
              I want previously answered questions to be prefilled,
              so I don't waste my time answering the same question twice" do
      helper.answer_recipient_restrictions
            .answer_proposal_restrictions(eligible: false)
            .check_eligibility
      visit eligibility_proposal_fund_path(@proposal, Fund.second)
      helper.check_eligibility(remaining: 2)
      expect(page).to have_text 'please select from the list', count: 2
    end

    scenario "When I'm ineligible and try to access application details,
              I want to be told why I can't access them,
              so I understand what to do next" do
      helper.answer_recipient_restrictions
            .answer_proposal_restrictions(eligible: false)
            .check_eligibility
      visit apply_proposal_fund_path(@proposal, @fund)
      expect(current_path)
        .to eq eligibility_proposal_fund_path(@proposal, @fund)
    end

    scenario 'When I try check eligiblity but have reached the max free limit,
              I want to be able to upgrade,
              so I can continue to check eligibilities' do
      # check all (7) funds, 4 quiz eligible
      helper.answer_restrictions.check_eligibility

      # checked funds don't require upgrade
      click_link 'Funding'
      visit eligibility_proposal_fund_path(@proposal, Fund.first)
      expect(current_path)
        .to eq eligibility_proposal_fund_path(@proposal, Fund.first)

      # funds over MAX_FREE_LIMIT require upgrade
      click_link 'Funding'
      helper.visit_first_fund
      expect(current_path).to eq account_upgrade_path(@db[:recipient])
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
          expect(current_path).to eq eligible_proposal_funds_path(@proposal)
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
        visit ineligible_proposal_funds_path(@proposal)
        within '.insights', match: :first do
          click_link 'Ineligible'
          expect(current_path).to eq ineligible_proposal_funds_path(@proposal)
        end
      end
    end
  end
end
