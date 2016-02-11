require 'test_helper'

class FunderNavigationTest < ActionDispatch::IntegrationTest

  setup do
    @funder = create(:funder)
    create(:funder_attribute, funder: @funder)
    3.times { create(:grant, funder: @funder) }
    @funder.update_current_attribute
    create_and_auth_user!(role: 'Funder', organisation: @funder)
  end

  test 'clicking logo redirects to funder overview path' do
    visit funder_recent_path(@funder)
    find(:css, '.logo').click
    assert_equal funder_overview_path(@funder), current_path
  end

  test 'signing in redirects to funder overview' do
    expire_cookies
    visit sign_in_path
    within('#sign-in') do
      fill_in('email', with: @user.user_email)
      fill_in('password', with: @user.password)
    end
    click_button('Sign in')
    assert_equal funder_overview_path(@funder), current_path
  end

end
