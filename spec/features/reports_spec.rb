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

  scenario 'updates when changes made to opportunities' do
    opp_update_date = proposal.collection.opportunities_last_updated_at
    proposal.update_column(:updated_at, opp_update_date - 1.day)
    expect(proposal.updated_at).to be < opp_update_date

    visit report_path(proposal)
    proposal.reload
    expect(proposal.updated_at).to be > opp_update_date
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

  context 'with collection' do
    before { visit report_path(proposal) }

    scenario 'breadcrumbs' do
      expect(page).to have_link(proposal.collection.name)
    end

    scenario 'new report link' do
      expect(page).to have_link('New report')
    end
  end

  context 'without collection (legacy)' do
    before do
      proposal.update_columns(collection_id: nil, collection_type: nil)
      visit report_path(proposal)
    end

    scenario 'breadcrumbs' do
      expect(page).to have_link("Report #{proposal.identifier}")
    end

    scenario 'new report link' do
      expect(page).not_to have_link('New report')
    end
  end

  context 'amount shown if' do
    scenario 'seeking funding' do
      visit report_path(proposal)
      expect(page).to have_text('Amount sought')
    end

    scenario 'seeking other' do
      proposal.update_column(:category_code, 101)
      visit report_path(proposal)
      expect(page).not_to have_text('Amount sought')
    end
  end

  context 'recipient name if' do
    scenario 'individual' do
      proposal.recipient.update_column(:category_code, 101)
      visit report_path(proposal)
      expect(page).not_to have_text('Name')
    end

    scenario 'organistion' do
      visit report_path(proposal)
      expect(page).to have_text('Name', count: 1)
    end
  end

  context 'recipient district if' do
    scenario 'present' do
      visit report_path(proposal)
      expect(page).to have_text('Area')
    end

    scenario 'missing' do
      proposal.recipient.update_column(:district_id, nil)
      visit report_path(proposal)
      expect(page).to have_text('Area')
    end
  end

  context 'recipient income band if' do
    scenario 'individual' do
      proposal.recipient.update_column(:category_code, 101)
      visit report_path(proposal)
      expect(page).not_to have_text('Annual income')
    end

    scenario 'organisation' do
      visit report_path(proposal)
      expect(page).to have_text('Annual income')
    end
  end

  context 'recipient website if' do
    scenario 'present' do
      visit report_path(proposal)
      expect(page).to have_text('Website')
    end

    scenario 'missing' do
      proposal.recipient.update_column(:website, nil)
      visit report_path(proposal)
      expect(page).to have_text('Website')
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
