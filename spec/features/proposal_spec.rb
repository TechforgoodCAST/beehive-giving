require 'rails_helper'
require_relative '../support/match_helper'
require_relative '../support/eligibility_helper'

feature 'Proposal' do
  let(:match) { MatchHelper.new }
  let(:eligibility) { EligibilityHelper.new }

  before(:each) do
    visit root_path
    @app.seed_test_db.setup_funds.create_recipient.with_user.sign_in
    @db = @app.instances
    @recipient = @db[:recipient]
    @fund = @db[:funds].first
    @theme = @db[:themes].first
    visit root_path
  end

  scenario 'When I use the site without a proposal,
            I want to be told why I am redirected,
            so I know what to do next' do
    [
      proposal_funds_path('missing'),
      eligible_proposal_funds_path('missing'),
      ineligible_proposal_funds_path('missing'),
      account_subscription_path(@recipient),
      account_upgrade_path(@recipient),
      edit_proposal_path('missing'),
      apply_proposal_fund_path('missing', @fund),
      proposal_fund_path('missing', @fund),
      theme_proposal_funds_path('missing', @theme.slug),
      new_feedback_path,
      edit_feedback_path(1)
    ].each do |path|
      visit path
      expect(current_path).to eq new_signup_proposal_path
    end
  end

  scenario 'When I sign into an incomplete proposal,
            I want to complete the proposal quickly,
            so I can see my results' do
    expect(current_path).to eq new_signup_proposal_path
    match.submit_proposal_form
    expect(current_path).to eq proposal_funds_path(Proposal.last)
  end

  context 'registered' do
    before(:each) do
      @app.create_registered_proposal
      @proposal = @app.instances[:registered_proposal]
    end

    scenario 'When I create my first proposal,
              I want to see options to change it or create a new one' do
      [
        proposal_funds_path(@proposal),
        eligible_proposal_funds_path(@proposal),
        ineligible_proposal_funds_path(@proposal)
      ].each do |path|
        visit path
        expect(page).to have_link(nil, href: edit_proposal_path(@proposal))
        expect(page).to have_link 'Change'
        expect(page).to have_link 'New'
      end
    end

    scenario 'clicking new proposal requires initial proposal to be complete and
              shows coming soon unless subscribed' do
      eligibility_helper = EligibilityHelper.new
      subscription_helper = SubscriptionsHelper.new
      stripe = StripeMock.create_test_helper
      visit root_path

      click_link 'New'

      # expect first to be completed
      expect(current_path).to eq edit_signup_proposal_path(@proposal)
      expect(page).to have_text 'Please fully complete'

      eligibility_helper.complete_proposal
      click_button 'Update and review recommendations'
      expect(current_path).to eq proposal_funds_path(@proposal)

      # expect upgrade prompt
      click_link 'New'
      expect(current_path).to eq account_upgrade_path(@recipient)

      # subscribe
      StripeMock.start

      subscription_helper.pay_by_card(stripe)
      expect(current_path).to eq thank_you_path(@recipient)

      # can create multiple proposals
      click_link 'Continue'
      expect(current_path).to eq proposal_funds_path(@proposal)

      StripeMock.stop
    end

    scenario 'cannot visit thank_you_path unless subscribed' do
      visit thank_you_path(@recipient)
      expect(current_path).to eq account_subscription_path(@recipient)
    end

    scenario "When I visit a proposal that doesn't belong to me,
              I want to be redirected,
              so I avoid an error" do
      @recipient.subscribe!
      @app.create_complete_proposal
      unauthorised_proposal = @app.instances[:complete_proposal]
      unauthorised_proposal.update(recipient: create(:recipient))

      visit proposal_funds_path(unauthorised_proposal)
      expect(current_path).to eq proposal_funds_path(@proposal)
    end

    scenario 'When I try to create a new proposal from the proposals index,
              I want to update my first proposal and see a message,
              so I can continue using the site' do
      visit root_path

      click_link 'Change'
      expect(current_path).to eq proposals_path

      click_link '+ New proposal'
      expect(current_path).to eq edit_signup_proposal_path(@proposal)
      expect(page).to have_text 'Please fully complete'
    end

    scenario 'When I have funding proposals,
              I want to be able to edit them,
              so I make any neccessary changes' do
      visit proposal_funds_path(@proposal)

      click_link 'Dashboard'
      expect(current_path).to eq proposals_path

      click_link 'Edit'
      expect(current_path).to eq edit_proposal_path(@proposal)

      [
        'Funding proposal',
        'Summary',
        'Requirements',
        'Beneficiaries',
        'Location',
        'Activities',
        'Outcomes',
        'Privacy'
      ].each do |text|
        expect(page).to have_text text
      end

      eligibility.complete_proposal
      click_button 'Update and review recommendations'
      expect(current_path).to eq proposal_funds_path(@proposal)
    end
  end

  context 'complete' do
    before(:each) do
      @app.create_complete_proposal
      @proposal = @app.instances[:complete_proposal]
    end

    scenario 'usubscribed and complete on proposals#index
              shows coming soon' do
      visit proposals_path
      click_link 'New proposal'
      expect(current_path).to eq account_upgrade_path(@recipient)
    end

    scenario 'subscribed and complete on proposals#index
              shows new proposal page' do
      @recipient.subscribe!

      visit proposals_path
      click_link 'New proposal'
      expect(current_path).to eq new_proposal_path
    end
  end

  context 'subscribed' do
    before(:each) do
      @match_helper = MatchHelper.new
      @eligibility_helper = EligibilityHelper.new
      @app.create_complete_proposal
      @recipient.subscribe!
      visit root_path
    end

    scenario 'When I am subscribed,
               I want to be able to create multiple proposals,
               so I can search for alternative funds' do
      click_link 'Change'
      expect(page).to have_css '.proposal', count: 1

      click_link 'New'
      @match_helper.fill_proposal_form
      @eligibility_helper.complete_proposal
      click_button 'Save and recommend funders'

      expect(current_path).to eq proposal_funds_path(Proposal.last)

      click_link 'Change'
      expect(page).to have_css '.proposal', count: 2
    end

    scenario 'When I have more than one proposal,
              I want to see which proposal I have currently selected,
              so I can understand the context of my results' do
      proposal1 = @app.instances[:complete_proposal]
      visit proposals_path
      click_link 'Funds', match: :first
      expect(current_path).to eq proposal_funds_path(proposal1)

      @app.create_registered_proposal
      proposal2 = @app.instances[:registered_proposal]
      visit proposals_path
      click_link 'Funds', match: :first
      expect(current_path).to eq proposal_funds_path(proposal2)
    end
  end

  scenario 'When I have an initial proposal,
            I want to be redirected and notified,
            so I can update my proposal' do
    @app.create_initial_proposal
    proposal = Proposal.last
    visit proposal_funds_path(proposal)
    expect(current_path).to eq new_signup_proposal_path
    expect(page).to have_text 'Your details are out of date'
  end

  scenario 'When I have an invalid organisation,
            I want to update my details,
            so I can continue to update my transferred proposal' do
    match.stub_charity_commission.stub_companies_house
    @app.create_initial_proposal
    recipient = build(:legacy_recipient, org_type: 4)
    recipient.set_slug
    recipient.save(validate: false)
    proposal = Proposal.last
    proposal.update_column(:recipient_id, recipient.id)
    @db[:user].organisation = recipient
    @db[:user].save
    @app.sign_in
    visit proposal_funds_path(proposal)
    expect(current_path).to eq edit_signup_recipient_path(recipient)
    expect(page).to have_text 'Your details are out of date'
    fill_in :recipient_street_address, with: 'London Road'
    select 'Less than £10k'
    select 'None', from: :recipient_employees
    select 'None', from: :recipient_volunteers
    click_button 'Next'
    expect(current_path).to eq new_signup_proposal_path
    expect(page).to have_text 'Your details are out of date'
  end
end
