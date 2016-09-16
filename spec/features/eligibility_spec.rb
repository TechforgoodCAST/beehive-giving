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

  scenario 'When I try check eligibility for a recommended fund,
            I want to see a list of all restrictions,
            so I can check to see if any apply' do
    helper.visit_first_fund
    expect(current_path).to eq fund_eligibility_path(@fund)
    expect(page).to have_css '.restriction', count: 2
  end

  scenario "When I run a check and I'm eligible,
            I want to see a link to apply for funding,
            so I can see further details about applying" do
    helper.visit_first_fund.answer.check
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
    helper.visit_first_fund.answer(eligible: false).check
    expect(page).to have_text 'You are ineligible, and did not meet 2 of the criteria below.'
    expect(page).to have_text 'You did not meet this criteria', count: 2

    click_link 'Why ineligible?'
    expect(current_path).to eq fund_eligibility_path(@fund)

    helper.answer.update
    expect(page).to have_text 'Apply'
    expect(page).to have_text 'Apply for funding'
  end

  scenario "When I've answered some eligibility questions in another fund,
            I want to only see outstanding questions,
            so I don't waste my time answering the same question twice" do
    helper.visit_first_fund.answer(eligible: false).check

    fund = Fund.first
    fund.restriction_ids = fund.restriction_ids << create(:restriction).id
    fund.save!
    expect(fund.restrictions.count).to eq 3

    visit fund_eligibility_path(fund)
    expect(page).to have_css '.restriction', count: 1
  end

  scenario "When I'm try to access application details before checking eligiblity,
            I want to be told why I can't access them,
            so I understand what to do next" do
    visit fund_apply_path(@fund)
    expect(current_path).to eq fund_eligibility_path(@fund)
  end

  scenario "When I'm ineligible and try to access application details,
            I want to be told why I can't access them,
            so I understand what to do next" do
    helper.visit_first_fund.answer(eligible: false).check
    visit fund_apply_path(@fund)
    expect(current_path).to eq fund_eligibility_path(@fund)
  end

  scenario 'When I try check eligiblity but have reached the max free limit,
            I want to be able to upgrade,
            so I can continue to check eligibilities'

  # TODO: if all questions matched then no need to check?
  # TODO: When I update
  # TODO: When I check multiples. feedback, etc.
  # TODO: running a check iterates one free usage
  # TODO: Truthy, invert

end
