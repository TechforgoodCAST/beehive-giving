require 'rails_helper'
require_relative '../support/eligibility_helper'

feature 'Eligibility' do
  let(:helper) { EligibilityHelper.new }

  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 7, open_data: true)
        .create_recipient
        .with_user
        .create_registered_proposal
        .sign_in
    @db = @app.instances
    @fund = Fund.first
    @proposal = @db[:registered_proposal]
    visit root_path
  end

  scenario 'invalid recipient restriction affects all proposals'

  # TODO: refactor
  scenario 'missing assessments created' do
    Assessment.last.destroy
    visit root_path
    expect(Assessment.count).to eq(7)
  end

  # TODO: refactor
  scenario 'when fund criteria are updated assessments are also updated' do
    old_fund_version = Fund.version
    Fund.first.update(name: 'New name')
    visit root_path
    Assessment.all.each do |a|
      expect(a.fund_version).not_to eq(old_fund_version)
      expect(a.fund_version).to eq(Fund.version)
    end
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
    visit apply_path(@fund, @proposal)
    expect(current_path).to eq(account_upgrade_path(@proposal.recipient))
  end

  scenario 'When I select a restriction that is inverted,
            I want it to be recorded as eligible,
            so I recieve an accurate check' do
    @fund.restrictions.first.update(invert: true)
    helper.visit_first_fund.complete_proposal.submit_proposal
    within "label[for=check_question_#{@fund.restrictions.first.id}" \
           '_true]' do
      expect(page).to have_text 'Yes'
    end
    helper.answer_restrictions(@fund).check_eligibility
    expect(page).to have_text 'Eligible'
  end

  context 'complete proposal' do
    before(:each) do
      helper.visit_first_fund.complete_proposal.submit_proposal
    end

    scenario "When I only answer recipient restrictions,
              I want them to be saved,
              so that I don't have to resubmit them" do
      helper.answer_recipient_restrictions(@fund).check_eligibility
      expect(page).to have_css '.quiz input[type=radio][checked=checked]', count: 2
    end

    scenario 'When I visit a fund without recipient restrictions,
              I want to only see proposal restrictions,
              so I avoid answering unnecessary questions' do
      helper.remove_restrictions(@fund, 'Recipient')
      helper.answer_proposal_restrictions(@fund).check_eligibility
      expect(page).not_to have_css '.restriction_recipient_question'
      expect(page).to have_text 'Eligible'
    end

    scenario 'When I only submit answers to proposal restrictions,
              I want the check to be invalid,
              so I avoid accidently checking a fund' do
      helper.answer_proposal_restrictions(@fund).check_eligibility
      expect(page).to have_link('Complete this check')
      # TODO: expect(page).to have_text('3 of 5 questions answered.')
    end

    scenario 'When I only submit answers to recipient restrictions,
              I want the check to be invalid,
              so I avoid accidently checking a fund' do
      helper.answer_recipient_restrictions(@fund).check_eligibility
      expect(page).to have_link('Complete this check')
      # TODO: expect(page).to have_text '2 of 5 questions answered.'
    end

    scenario 'When I visit a fund without proposal restrictions,
              I want to only see recipient restrictions,
              so I avoid answering unnecessary questions' do
      helper.remove_restrictions(@fund, 'Proposal')
      helper.answer_recipient_restrictions(@fund).check_eligibility
      expect(page).not_to have_css '.restriction_proposal_question'
      expect(page).to have_text 'Eligible'
    end

    scenario "When I run a check and I'm eligible,
              I want to see a link to apply for funding,
              so I can see further details about applying" do
      helper.answer_restrictions(@fund).check_eligibility
            .answer_priorities(@fund).check_suitability
      click_link 'Reveal', match: :first
      click_link 'Apply ❯'
      expect(current_path).to eq(apply_path(@fund, @proposal))
    end

    scenario "When I run a check and I'm ineligible,
              I want to see which options did not meet the criteria,
              so I can correct them if neccesary" do
      helper.answer_recipient_restrictions(@fund)
            .answer_proposal_restrictions(@fund, eligible: false)
            .check_eligibility
      expect(page).to have_text 'You are ineligible, and do not meet 3 of ' \
                                'the criteria below.'
      expect(page).to have_text 'You did not meet this criteria', count: 3

      helper.answer_restrictions(@fund).check_eligibility
      expect(page).to have_text 'Apply'
      expect(page).to have_text 'Apply ❯'

      # TODO: No feedback for unlocked funds
    end

    scenario "When I check a fund with shared restrictions,
              I want associated funds to be checked, so
              I don't waste time checking funds with the same restrictions" do
      helper.answer_restrictions(@fund).check_eligibility
      quizzes_checked = Assessment.where.not(eligibility_quiz: nil).size
      expect(quizzes_checked).to eq(4)
    end

    scenario "When I've answered some eligibility questions in another fund,
              I want previously answered questions to be prefilled,
              so I don't waste my time answering the same question twice" do
      Fund.limit(5).order(id: :desc).destroy_all # leave two funds remaining
      helper.answer_recipient_restrictions(@fund)
            .answer_proposal_restrictions(@fund, eligible: false)
            .check_eligibility
      visit fund_path(Fund.last, @proposal)

      helper.check_eligibility
      # 3 questions previously answered should be checked
      # TODO: expect(page).to have_text '3 of 5 questions answered.'
      expect(page).to have_css '.quiz input[type=radio][checked=checked]', count: 3
    end

    scenario "When I'm ineligible and try to access application details,
              I want to be told why I can't access them,
              so I understand what to do next" do
      helper.answer_recipient_restrictions(@fund)
            .answer_proposal_restrictions(@fund, eligible: false)
            .check_eligibility
      click_link 'Reveal', match: :first
      visit apply_path(@fund, @proposal)
      expect(current_path).to eq(account_upgrade_path(@proposal.recipient))
    end
  end
end
