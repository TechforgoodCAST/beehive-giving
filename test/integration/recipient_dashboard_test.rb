require 'test_helper'

class RecipientDashboardTest < ActionDispatch::IntegrationTest

  test 'dashboard is locked for user with no profiles' do
    @recipient = create(:recipient)
    3.times { create(:funder, :active_on_beehive => true) }
    create_and_auth_user!(:organisation => @recipient)
    visit '/dashboard'
    assert page.has_content?("See how you compare (Locked)")
    assert_equal all(".uk-icon-lock").length, 3
  end

  test 'that clicking the comparison link takes you a page with options to unlock' do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    create_and_auth_user!(:organisation => @recipient)
    visit '/dashboard'
    find_link('See how you compare (Locked)').click
    assert page.has_content?(@funder.name)
    assert page.has_link?('Complete Profile')
    assert page.has_content?('Pay (coming soon)')
  end

  test 'that clicking the comparison link with a profile gives an unlock button' do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    visit '/dashboard'
    find_link('See how you compare (Locked)').click
    assert page.has_content?(@funder.name)
    assert page.has_link?('Unlock Funder')
  end

  test 'recipient with 3 profiles can only pay' do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    create_and_auth_user!(:organisation => @recipient)
    visit '/dashboard'
    find_link('See how you compare (Locked)').click
    puts page.body
    assert_not page.has_link?('Complete Profile')
    assert_not page.has_link?('Unlock Funder')
    assert page.has_content?('Pay (coming soon)')
  end

  # test if a recipient has one profile then the first funder is unlocked
  # test recipient can only unlock 3 funders
  # test dashboard has link to edit organisation
  # test dashboard has link to edit profiles
end
