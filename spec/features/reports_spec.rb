require 'rails_helper'

feature 'Reports' do
  include SignInHelper

  let(:collection) { create(:funder_with_funds) }
  let(:proposal) { create(:proposal) }
  let(:user) { create(:user_with_password) }

  before { Assessment.analyse_and_update!(collection.funds, proposal) }

  context 'signed out' do
    scenario 'can view public report' do
      visit report_path(proposal)
      expect(current_path).to eq(report_path(proposal))
      collection.funds.each { |fund| expect(page).to have_text(fund.name) }
    end

    scenario 'cannot view own private report' do
      expect(page.status_code).to eq(403)
      expect(page).to have_text('Forbidden')
    end

    scenario 'can view any private report with token' do
      expect(page).to have_current_path(report_path(any_proposal, t: any_proposal.access_token))
    end
  end

  context 'signed in' do
    before { sign_in(user) }

    scenario 'can view public report' do
      visit report_path(proposal)
      expect(current_path).to eq(report_path(proposal))
      collection.funds.each { |fund| expect(page).to have_text(fund.name) }
    end

    scenario 'can view own private report' do
      expect(page).to have_current_path(report_path(proposal, t: proposal.access_token))
    end

    scenario 'can view any private report with token' do
      expect(page).to have_current_path(report_path(any_proposal, t: any_proposal.access_token))
    end
  end
end
