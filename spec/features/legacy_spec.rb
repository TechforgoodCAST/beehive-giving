require 'rails_helper'

feature 'Legacy' do
  include ShowMeTheCookies

  context 'legacy' do
    let(:organisation_type) { 'Recipient' }
    let(:user) { create(:user, organisation_type: organisation_type) }

    before do
      create_cookie(:auth_token, user.auth_token)
      visit root_path
    end

    context 'funder' do
      let(:organisation_type) { 'Funder' }
      it { expect(current_path).to eq(legacy_funder_path) }
      it { expect_sign_out }
    end

    scenario 'fundraiser without recipient' do
      expect(current_path).to eq(legacy_fundraiser_path)
      expect_sign_out
    end

    scenario 'fundraiser without proposal' do
      expect(current_path).to eq(legacy_fundraiser_path)
      expect_sign_out
    end
  end

  context 'redirect' do
    let(:user) { create(:registered_user) }
    let(:proposal) { recipient.proposals.last }
    let(:recipient) { user.organisation }

    before { create_cookie(:auth_token, user.auth_token) }

    context 'fundraiser with basics proposal' do
      before do
        user.update_column(:first_name, nil)
        proposal.update_columns(state: 'basics', title: nil)
      end

      scenario { expect_proposal_edit }
    end

    context 'fundraiser with invalid proposal' do
      before { proposal.update_columns(state: 'invalid', title: nil) }
      scenario { expect_proposal_edit }
    end

    context 'fundraiser with incomplete proposal'  do
      before do
        proposal.update_columns(state: 'incomplete', title: nil, tagline: nil)
      end

      scenario { expect_proposal_edit }
    end
  end

  def expect_sign_out
    # TODO: implement
  end

  def expect_proposal_edit
    visit root_path
    expect(current_path).to eq(edit_proposal_path(proposal))
    expect(page).to have_text('IMPORTANT')

    click_button 'Update proposal'
    expect(page).to have_css('.field_with_errors')

    expect_sign_out
  end
end
