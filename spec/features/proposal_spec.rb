require 'rails_helper'

feature 'Proposal' do
  include ShowMeTheCookies

  let(:user) { create(:registered_user) }
  let(:proposal) { recipient.proposals.last }
  let(:recipient) { user.organisation }

  before { create_cookie(:auth_token, user.auth_token) }

  scenario 'cannot create multiple proposals unless subscribed' do
    visit root_path
    click_link 'Change'
    click_link 'New proposal'

    expect(current_path).to eq(account_upgrade_path(recipient))
  end

  scenario 'can create multiple once subscribed' do
    recipient.update(country: proposal.countries.first.alpha2)
    recipient.reload
    recipient.subscribe!

    visit root_path
    click_link 'Change'
    click_link 'New proposal'
    complete_proposal_form
    click_button 'Check proposal'

    expect(current_path).to eq(funds_path(Proposal.last))
    expect(page).to have_text('Proposal2')
  end

  scenario 'listing' do
    build(:proposal, recipient: recipient).save(validate: false)
    visit proposals_path
    expect(page).to have_text('Edit', count: 2)
  end

  scenario 'editable' do
    update = 'Edited proposal title'

    visit funds_path(proposal)
    click_link 'Dashboard'
    click_link 'Edit'
    fill_in :proposal_title, with: update
    click_button 'Update proposal'

    expect(current_path).to eq(proposals_path)
    expect(page).to have_text(update)
  end

  scenario 'only editable if belonging account' do
    unauthorised = create(:proposal)
    visit edit_proposal_path(unauthorised)
    expect(current_path).to eq(proposals_path)
  end

  def complete_proposal_form
    fill_in :proposal_title, with: 'Proposal2'
    fill_in :proposal_tagline, with: 'Description'
    select 'Capital funding'
    fill_in :proposal_total_costs, with: 10_000
    choose :proposal_all_funding_required_true
    fill_in :proposal_funding_duration, with: 12
    select Theme.last.name
    select 'An entire country'
    choose :proposal_private_true
  end
end
