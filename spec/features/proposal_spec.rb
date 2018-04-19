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

    expect(current_path).to eq(new_proposal_path)

    # TODO: submit form
  end

  scenario 'listing' do
    build(:proposal, recipient: recipient).save(validate: false)
    visit proposals_path
    expect(page).to have_text('Edit', count: 2)
  end

  scenario 'editable' do
    visit funds_path(proposal)
    click_link 'Dashboard'
    click_link 'Edit'
    # TODO: edit proposal title

    expect(current_path).to have_text('Edited proposal title')
  end

  scenario 'only editable if belonging account' do
    unauthorised = create(:proposal)
    visit edit_proposal_path(unauthorised)
    expect(current_path).to eq(proposals_path)
  end
end
