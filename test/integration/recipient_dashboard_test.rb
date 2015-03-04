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
    assert page.has_content?('Coming soon')
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
    assert page.has_content?('Coming soon')
  end

  test "recipient can unlock a funder" do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)

    visit '/dashboard'
    find_link('See how you compare (Locked)').click

    assert_equal "/comparison/#{@funder.slug}/gateway", current_path
    find_link('Unlock Funder').click

    assert_equal "/comparison/#{@funder.slug}", current_path
  end

  test "recipient is directed to gateway for locked funders" do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)

    visit "/comparison/#{@funder.slug}"
    assert_equal "/comparison/#{@funder.slug}/gateway", current_path
  end

  test "recipient can see unlocked link on dashboard for an unlocked funder" do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    @recipient.unlock_funder!(@funder)

    visit "/dashboard"
    assert_not page.has_content?('See how you compare (Locked)')
  end

  test "recipient can only unlock 3 funders" do
    @recipient = create(:recipient)
    @funders   = []
    4.times { @funders << create(:funder, :active_on_beehive => true) }
    5.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    create_and_auth_user!(:organisation => @recipient)

    @recipient.unlock_funder!(@funders[0])
    @recipient.unlock_funder!(@funders[1])
    @recipient.unlock_funder!(@funders[2])

    visit "/comparison/#{@funders[3].slug}"

    assert_equal "/comparison/#{@funders[3].slug}/gateway", current_path
    assert page.has_content?("You can only unlock 3 funders on the free plan")
  end

end
