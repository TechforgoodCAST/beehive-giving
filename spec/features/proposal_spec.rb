require 'rails_helper'
require_relative '../support/match_helper'
require_relative '../support/eligibility_helper'

feature 'Proposal' do

  let(:match) { MatchHelper.new }
  let(:eligibility) { EligibilityHelper.new }

  before(:each) do
    @app.seed_test_db.create_recipient.with_user.sign_in
    @db = @app.instances
    @recipient = @db[:recipient]
    visit root_path
  end

  scenario 'When I sign into an incomplete proposal,
            I want to complete the proposal quickly,
            so I can see my results' do
    expect(current_path).to eq new_recipient_proposal_path(@recipient)
    match.submit_proposal_form
    expect(current_path).to eq recommended_funds_path
  end

  scenario 'When I have funding proposals,
            I want to be able to edit them,
            so I make any neccessary changes' do
    @app.create_registered_proposal
    @proposal = Proposal.last
    visit recommended_funds_path
    within '.uk-dropdown' do
      click_link 'Funding proposals'
    end
    expect(current_path).to eq recipient_proposals_path(@recipient)
    click_link 'Update proposal'
    expect(page).to have_text 'Improve your results'
    eligibility.complete_proposal
    # TODO: redirect to edit_recipient_proposal_path
    click_button 'Update and review recommendations'
    within '.uk-dropdown' do
      click_link 'Funding proposals'
    end
    click_link 'Update proposal'
    expect(current_path).to eq edit_recipient_proposal_path(@recipient, @proposal)
    click_button 'Save and recommend funders'
    expect(current_path).to eq recommended_funds_path
  end

end
