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

  it 'accounts'
  #   expect_path([
  #     account_subscription_path(@recipient),
  #     account_upgrade_path(@recipient)
  #   ])
  # end

  it 'eligibilities' do
    expect_path([
                  eligibility_proposal_fund_path(@proposal, @fund)
                ])
  end

  it 'enquiries' do
    expect_path([
                  apply_proposal_fund_path(@proposal, @fund)
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
                  proposal_fund_path(@proposal, @fund),
                  recommended_proposal_funds_path(@proposal),
                  eligible_proposal_funds_path(@proposal),
                  ineligible_proposal_funds_path(@proposal),
                  all_proposal_funds_path(@proposal),
                  tag_proposal_funds_path(@proposal, 'Tag')
                ])
  end

  it 'proposals' do
    expect_path([
                  new_recipient_proposal_path(@recipient),
                  edit_recipient_proposal_path(@recipient, @proposal),
                  recipient_proposals_path(@recipient)
                ])
  end

  it 'recipients'
  #   expect_path([
  #                 recipient_path(@recipient),
  #                 edit_recipient_path(@recipient)
  #               ])
  # end

  it 'signup' do
    expect_path([
                  signup_organisation_path,
                  unauthorised_path
                ])
  end
end
