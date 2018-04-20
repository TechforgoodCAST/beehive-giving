require 'rails_helper'

feature 'Legacy' do
  include ShowMeTheCookies

  context 'legacy' do
    let(:user) { create(:user) }

    context 'funder' do
      before do
        user.update(organisation: create(:funder))
        sign_in
      end

      scenario { expect(current_path).to eq(legacy_funder_path) }
      scenario('can sign out') { expect_sign_out }
    end

    context 'fundraiser without recipient' do
      before { sign_in }

      scenario('redirected') { expect(current_path).to eq(legacy_fundraiser_path) }
      scenario('can sign out') { expect_sign_out }

      scenario 'can delete old account' do
        expect(User.count).to eq(1)
        expect(Recipient.count).to eq(0)
        click_link 'Delete old account'
        expect(User.count).to eq(0)
        expect(current_path).to eq(root_path)
      end
    end

    context 'fundraiser without proposal' do
      before do
        user.update(organisation: create(:recipient))
        sign_in
      end

      scenario('redirected') { expect(current_path).to eq(legacy_fundraiser_path) }
      scenario('can sign out') { expect_sign_out }

      scenario 'can delete old account' do
        expect(User.count).to eq(1)
        expect(Recipient.count).to eq(1)
        click_link 'Delete old account'
        expect(User.count).to eq(0)
        expect(Recipient.count).to eq(0)
        expect(current_path).to eq(root_path)
      end
    end
  end

  context 'redirect' do
    let(:user) { create(:registered_user) }
    let(:proposal) { recipient.proposals.last }
    let(:recipient) { user.organisation }

    before { sign_in }

    context 'fundraiser with basics proposal' do
      before do
        user.update_column(:first_name, nil)
        proposal.update_columns(state: 'basics', title: nil)
      end

      scenario { expect_proposal_edit }
      scenario('can sign out') { expect_sign_out }
    end

    context 'fundraiser with invalid proposal' do
      before { proposal.update_columns(state: 'invalid', title: nil) }
      scenario { expect_proposal_edit }
      scenario('can sign out') { expect_sign_out }
    end

    context 'fundraiser with incomplete proposal' do
      before do
        proposal.update_columns(state: 'incomplete', title: nil, tagline: nil)
      end

      scenario { expect_proposal_edit }
      scenario('can sign out') { expect_sign_out }
    end
  end

  def expect_proposal_edit
    visit root_path
    expect(current_path).to eq(edit_proposal_path(proposal))
    expect(page).to have_text('IMPORTANT')

    click_button 'Update proposal'
    expect(page).to have_css('.field_with_errors')
  end

  def expect_sign_out
    click_link 'Sign out'
    expect(current_path).to eq(root_path)
  end

  def sign_in
    visit sign_in_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Sign in'
  end
end
