require 'rails_helper'

describe 'Ensure logged in' do
  before(:each) do
    @app.seed_test_db
        .setup_funds
        .create_recipient
        .with_user
        .create_proposal
    @db = @app.instances
    @user = @db[:user]
    @recipient = @db[:recipient]
    @proposal = @db[:proposal]
    @fund = @db[:funds].first
    @theme = @db[:themes].first
  end

  def expect_path(*paths)
    paths.each do |path|
      visit path
      assert_equal(sign_in_path, current_path)
    end
  end

  it 'accounts' do
    expect_path(
      account_subscription_path(@recipient)
    )
  end

  it 'charges' do
    expect_path(
      account_upgrade_path(@recipient),
      thank_you_path(@recipient)
    )
  end

  it 'enquiries' do
    expect_path(
      apply_path(@fund, @proposal)
    )
  end

  it 'feedback' do
    expect_path(
      new_feedback_path,
      edit_feedback_path(create(:feedback, user: @user))
    )
  end

  it 'proposals' do
    expect_path(
      proposals_path,
      new_proposal_path,
      edit_proposal_path(@proposal)
    )
  end

  it 'recipients' do
    expect_path(
      account_organisation_path(@recipient)
    )
  end

  it 'users' do
    expect_path(
      account_path
    )
  end

  it 'cannot sign in with missing email' do
    visit sign_in_path
    fill_in :email, with: 'missing@email.com'
    fill_in :password, with: '123123a'
    click_button 'Sign in'
    expect(current_path).to eq(new_password_reset_path)
  end
end
