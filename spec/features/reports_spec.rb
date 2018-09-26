require 'rails_helper'

feature 'Reports' do
  scenario 'reports produced for active opportunities in collection'

  context 'signed out' do
    scenario 'can view public report' do
      expect(current_path).to eq(report_path(proposal))
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
    scenario 'can view public report' do
      expect(current_path).to eq(report_path(proposal))
    end

    scenario 'can view own private report' do
      expect(page).to have_current_path(report_path(proposal, t: proposal.access_token))
    end

    scenario 'can view any private report with token' do
      expect(page).to have_current_path(report_path(any_proposal, t: any_proposal.access_token))
    end
  end
end
