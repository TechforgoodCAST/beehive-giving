require 'rails_helper'

describe 'Ensure logged in' do

  before(:each) do
    @app.seed_test_db
        .setup_funds
        .create_recipient
        .with_user
        .create_registered_proposal
    @db = @app.instances
    @user = @db[:user]
    @recipient = @db[:recipient]
    @proposal = @db[:registered_proposal]
    @fund = @db[:funds].first
  end

  def expect_path(array)
    array.each do |path|
      visit path
      assert_equal sign_in_path, current_path
    end
  end

  it 'accounts' do
    expect_path([
      account_subscription_path(@recipient),
      account_upgrade_path(@recipient)
    ])
  end

  it 'eligibilities' do
    expect_path([
      fund_eligibility_path(@fund)
    ])
  end

  it 'enquiries' do
    expect_path([
      fund_apply_path(@fund)
    ])
  end

  it 'feedback' do
    expect_path([
      new_feedback_path,
      edit_feedback_path(create(:feedback, user: @user))
    ])
  end

  it 'funds' do
    expect_path([
      fund_path(@fund),
      tag_path('Tag')
    ])
  end

  it 'proposals' do
    expect_path([
      new_recipient_proposal_path(@recipient),
      edit_recipient_proposal_path(@recipient, @proposal),
      recipient_proposals_path(@recipient)
    ])
  end

  it 'recipients' do
    expect_path([
      edit_recipient_path(@recipient),
      recommended_funds_path,
      eligible_funds_path,
      ineligible_funds_path,
      all_funds_path,
      recipient_path(@recipient)
    ])
  end

  it 'signup' do
    expect_path([
      signup_organisation_path,
      unauthorised_path
    ])
  end

  context 'deprecated' do
    before(:each) do
      @funder = create(:funder)
    end

    it 'funders' do
      expect_path([
        funder_overview_path(@funder),
        funder_map_path(@funder),
        funder_map_data_path(@funder),
        funders_map_all_path(@funder),
        funder_district_path(@funder, District.last),
        funders_comparison_path,
        explore_funder_path(@funder),
        eligible_funder_path(@funder),
        funders_path,
        funder_path(@funder)
      ])
    end
  end
end
