require 'rails_helper'

feature 'Reports' do
  include SignInHelper

  let(:collection) { create(:funder_with_funds) }
  let(:proposal) { create(:proposal) }
  let(:user) { create(:user_with_password) }

  before { Assessment.analyse_and_update!(collection.funds, proposal) }

  scenario 'not found' do
    visit report_path('missing')
    expect(page.status_code).to eq(404)
    expect(page).to have_text('Not found')
  end

  context 'signed out' do
    scenario { can_view_public_report }

    context do
      let(:proposal) { create(:proposal, private: Time.zone.now) }

      scenario 'cannot view own private report' do
        visit report_path(proposal)
        expect(current_path).to eq(sign_in_lookup_path)
      end

      scenario { can_view_any_private_report_with_token(proposal) }
    end

    scenario 'cannot pick a report to view from reports list' do
      visit reports_path
      expect(current_path).to eq(sign_in_lookup_path)
    end
  end

  context 'signed in' do
    before { sign_in(user) }

    scenario { can_view_public_report }

    context do
      let(:proposal) { create(:proposal, private: Time.zone.now, user: user) }
      let(:unowned) { create(:proposal, private: Time.zone.now) }

      scenario 'can view own private report' do
        visit report_path(proposal)
        expect(current_path).to eq(report_path(proposal))
      end

      scenario { can_view_any_private_report_with_token(unowned) }

      scenario 'cannot view anothers private report' do
        visit report_path(unowned)
        expect(page.status_code).to eq(403)
        expect(page).to have_text('Forbidden')
      end

      scenario 'can pick a report to view from reports list' do
        visit reports_path
        expect(current_path).to eq(reports_path)
        click_link('View full report')
        expect(current_path).to eq(report_path(proposal))
      end
    end
  end

  def can_view_public_report
    visit report_path(proposal)
    expect(current_path).to eq(report_path(proposal))
    collection.funds.each { |fund| expect(page).to have_text(fund.name) }
  end

  def can_view_any_private_report_with_token(proposal)
    path = report_path(proposal, t: proposal.access_token)
    visit path
    expect(page).to have_current_path(path)
  end
end
