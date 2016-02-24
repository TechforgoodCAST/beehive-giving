require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
  end

  def assert_path(array)
    array.each do |path|
      visit path
      assert_equal sign_in_path, current_path
    end
  end
  
  test 'ensure logged in for feedback' do
    visit new_feedback_path
    assert_equal sign_in_path, current_path
  end

  test 'ensure logged in for funders' do
    assert_path([
      # Non-profit
      funders_path,
      funders_comparison_path,

      # Funder
      explore_funder_path(@funder),
      eligible_funder_path(@funder),
      funder_path(@funder)
    ])
  end

  test 'ensure logged in for grants' do
    @grant = create(:grant, :funder => @funder)
    assert_path([
      funder_grants_path(@funder),
      new_funder_grant_path(@funder),
      edit_funder_grant_path(@funder, @grant)
    ])
  end

  test 'ensure logged in for profiles' do
    @profile = create(:profile, :organisation => @recipient)
    assert_path([
      recipient_profiles_path(@recipient),
      new_recipient_profile_path(@recipient),
      edit_recipient_profile_path(@recipient, @profile)
    ])
  end

  test 'ensure logged in for recipient attributes' do
    @recipient_attribute = create(:recipient_attribute)
    assert_path([
      new_recipient_attribute_path(@recipient),
      edit_recipient_attribute_path(@recipient, @recipient_attribute)
    ])
  end

  test 'ensure logged in for recipients' do
    assert_path([
      edit_recipient_path(@recipient),
      # recipient_path(@recipient),

      # Non-profit
      funder_path(@funder),
      # recipient_public_path(@recipient),

      # Eligibility
      recipient_eligibility_path(@recipient)
    ])
  end

  test 'ensure logged in for signup' do
    visit signup_organisation_path
    assert_equal sign_in_path, current_path
  end

  test 'ensure logged in for users' do
    @user = (create(:user))
    assert_path([
      users_path,
      user_path(@user)
    ])
  end

end
