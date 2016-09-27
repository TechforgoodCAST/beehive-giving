require 'rails_helper'
require_relative '../support/match_helper'
require_relative '../support/eligibility_helper'

feature 'Proposal' do

  let(:match) { MatchHelper.new }
  let(:eligibility) { EligibilityHelper.new }

  before(:each) do
    @app.seed_test_db.setup_funds.create_recipient.with_user.sign_in
    @db = @app.instances
    @recipient = @db[:recipient]
    @fund = @db[:funds].first
    visit root_path
  end

  scenario 'When I use the site without a proposal,
            I want to be told why I am redirected,
            so I know what to do next' do
    [
      recommended_funds_path,
      eligible_funds_path,
      ineligible_funds_path,
      all_funds_path,
      account_subscription_path(@recipient),
      account_upgrade_path(@recipient),
      edit_recipient_proposal_path(@recipient),
      fund_eligibility_path,
      fund_apply_path,
      fund_path(@fund),
      tag_path('Tag'),
      new_feedback_path,
      edit_feedback_path(1)
    ].each do |path|
      visit path
      expect(current_path).to eq new_recipient_proposal_path(@recipient)
    end
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
    [
      'Improve your results',
      'Summary',
      'Activities',
      'Outcomes'
    ].each do |text|
      expect(page).to have_text text
    end
    eligibility.complete_proposal
    # TODO: redirect to edit_recipient_proposal_path
    click_button 'Update and review recommendations'
    within '.uk-dropdown' do
      click_link 'Funding proposals'
    end
    click_link 'Update proposal'
    expect(current_path).to eq edit_recipient_proposal_path(@recipient, @proposal)
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
    click_button 'Save and recommend funders'
    expect(current_path).to eq recommended_funds_path
  end

  context 'legacy' do
    before(:each) do
      @current_profile = build(:current_profile, organisation: @recipient,
        countries: @db[:countries], districts: @db[:districts],
        age_groups: @db[:age_groups], beneficiaries: @db[:beneficiaries])
      @legacy_profile = build(:legacy_profile, organisation: @recipient,
        countries: @db[:countries], districts: @db[:districts],
        age_groups: @db[:age_groups], beneficiaries: @db[:beneficiaries])
    end


    scenario "When I have a 'current profile',
              I want to be redirected to the edit proposal page,
              so I can update my proposal" do
      @current_profile.save!
      visit recommended_funds_path
      expect(page).to have_text 'Your details are out of date'
      expect(current_path).to eq edit_recipient_proposal_path(@recipient, Proposal.last)
    end

    scenario "When I have a 'legacy profile',
              I want to be redirected to the edit proposal page,
              so I can update my proposal" do
      @legacy_profile.save(validate: false)
      visit recommended_funds_path
      expect(page).to have_text 'Your details are out of date'
      expect(current_path).to eq edit_recipient_proposal_path(@recipient, Proposal.last)
    end

    context 'no proposal' do
      before(:each) do
        @recipient.proposals.destroy_all
      end

      scenario "When I have a 'transferred proposal',
                I want it to populate from my 'current profile',
                so my previous work is retained" do
        @current_profile.gender = 'Other'
        @current_profile.save!
        visit recommended_funds_path
        expect(current_path).to eq new_recipient_proposal_path(@recipient)
        expect(find('#proposal_gender').value).to eq 'Other'
        # TODO: check other fields
      end

      scenario "When I have a 'transferred proposal',
                I want it to populate from my 'legacy profile',
                so my previous work is retained" do
        @legacy_profile.gender = 'Other'
        @legacy_profile.save(validate: false)
        visit recommended_funds_path
        expect(current_path).to eq new_recipient_proposal_path(@recipient)
        expect(find('#proposal_gender').value).to eq 'Other'
        # TODO: check other fields
      end
    end

    scenario 'When I have an invalid organisation,
              I want to update my details,
              so I can continue to update my transferred proposal' do
      match.stub_charity_commission.stub_companies_house
      @recipient = build(:legacy_recipient, charity_number: '1161998')
      @recipient.set_slug
      @recipient.save(validate: false)
      @current_profile.organisation = @recipient
      @current_profile.save!
      @db[:user].organisation = @recipient
      @db[:user].save
      @app.sign_in
      visit recommended_funds_path
      expect(current_path).to eq edit_recipient_path(@recipient)
      expect(page).to have_text 'Your details are out of date'
      select 'Less than £10k'
      select 'None', from: :recipient_employees
      select 'None', from: :recipient_volunteers
      click_button 'Next'
      expect(current_path).to eq new_recipient_proposal_path(@recipient)
      expect(page).to have_text 'Your details are out of date'
    end
  end

end
