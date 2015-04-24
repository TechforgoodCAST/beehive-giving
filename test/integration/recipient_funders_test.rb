require 'test_helper'

class RecipientFundersTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  # test 'who is @recipient on funders' do
  # end

  test 'funders are locked for user with no profiles' do
    3.times { create(:funder, :active_on_beehive => true) }
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    assert page.has_content?("See how you compare (Locked)")
    assert_equal all(".uk-icon-lock").length, 3
  end

  test 'that clicking the comparison link takes you a page with options to unlock' do
    @funder = create(:funder, :active_on_beehive => true)
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    find_link('See how you compare (Locked)').click
    assert page.has_link?('Complete Profile')
  end

  test 'that clicking the comparison link with a profile gives an unlock button' do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    find_link('See how you compare (Locked)').click
    assert page.has_link?('Unlock Funder')
  end

  test 'recipient with 3 profiles can only pay' do
    @recipient = create(:recipient, founded_on: "01/01/2005")
    @funder = create(:funder, :active_on_beehive => true)
    4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    find_link('See how you compare (Locked)').click
    puts page.body
    assert_not page.has_link?('Complete Profile')
    assert_not page.has_link?('Unlock Funder')
  end

  test "recipient can unlock a funder" do
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    find_link('See how you compare (Locked)').click
    assert_equal "/comparison/#{@funder.slug}/gateway", current_path
    find_link('Unlock Funder').click
    assert_equal "/comparison/#{@funder.slug}", current_path
  end

end
