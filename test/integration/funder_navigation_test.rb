# TODO: deprecated
require 'test_helper'

class FunderNavigationTest < ActionDispatch::IntegrationTest

  setup do
    seed_test_db
    @funder = create(:funder)
    create(:funder_attribute, funder: @funder, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    3.times { create(:grant, funder: @funder, countries: @countries, districts: @districts) }
    @funder.update_current_attribute
    create_and_auth_user!(role: 'Funder', organisation: @funder)
  end

  test 'clicking logo redirects to funder overview path' do
    skip
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

  test 'visiting overview after all funding map redirects' do
    visit '/funding/all/map'
    click_link('Overview')
    assert_equal '/funding/overview', current_path
  end

end
