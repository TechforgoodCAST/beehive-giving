# TODO: deprecated
require 'rails_helper'

feature 'DEPRECATED Funder' do
  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 7, open_data: true)
        .with_user(organisation: Funder.last, role: 'Funder')
        .deprecated_funders_setup
        .sign_in
    @db = @app.instances
    @funder = Funder.last
    @fund = Fund.last
    @user = User.last
    visit root_path
  end

  # scenario 'can only view district in their context'

  scenario 'cannot visit recipient paths' do
    [
      recommended_funds_path,
      eligible_funds_path,
      ineligible_funds_path,
      all_funds_path,
      fund_eligibility_path(@fund),
      fund_apply_path(@fund),
      new_recipient_proposal_path(@funder),
      edit_recipient_proposal_path(@funder),
      recipient_proposals_path(@funder),
      new_feedback_path,
      edit_feedback_path(create(:feedback, user: @user))
    ].each do |path|
      visit path
      expect(current_path).to eq funder_overview_path(@funder)
    end
  end

  scenario 'clicking logo redirects to funder overview path' do
    visit funder_map_path(@funder)
    find(:css, '.logo').click
    expect(current_path).to eq funder_overview_path(@funder)
  end

  scenario 'signing in redirects to funder overview' do
    @app.sign_out
    visit funder_overview_path(@funder)
    fill_in :email, with: @user.user_email
    fill_in :password, with: 'password123'
    click_button('Sign in')
    expect(current_path).to eq funder_overview_path(@funder)
  end

  scenario 'visiting overview after all funding map redirects' do
    visit '/funding/all/map'
    click_link('Overview')
    expect(current_path).to eq '/funding/overview'
  end
end
