require 'test_helper'

class RecipientDashboardTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  test 'public cannot see organisation profile' do
    visit "/organisation/#{@recipient.slug}"
    assert_equal '/welcome', current_path
  end

  test 'only recipient can see organisation profile' do
    @recipient2 = create(:organisation)
    create_and_auth_user!(:organisation => @recipient)

    visit "/organisation/#{@recipient.slug}"
    assert_equal "/organisation/#{@recipient.slug}", current_path

    visit "/organisation/#{@recipient2.slug}"
    assert_equal '/funders', current_path
  end

  test 'funders can see all organisation profiles' do
    @recipient2 = create(:organisation)
    @funder = create(:funder)
    create_and_auth_user!(:organisation => @funder, :role => 'Funder')

    visit "/organisation/acme"
    assert_equal "/organisation/acme", current_path

    visit "/organisation/#{@recipient2.slug}"
    assert_equal "/organisation/#{@recipient2.slug}", current_path
  end

  test "recipient is directed to gateway for locked funders" do
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)

    visit "/comparison/#{@funder.slug}"
    assert_equal "/comparison/#{@funder.slug}/gateway", current_path
  end

  test "recipient can see unlocked link on funders index for an unlocked funder" do
    @funder = create(:funder, :active_on_beehive => true)
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    @recipient.unlock_funder!(@funder)

    visit "/funders"
    assert_not page.has_content?('See how you compare (Locked)')
  end

  test "recipient can only unlock 4 funders" do
    @recipient = create(:recipient, founded_on: "01/01/2005")
    @funders   = []
    5.times { @funders << create(:funder, :active_on_beehive => true) }
    4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    create_and_auth_user!(:organisation => @recipient)

    @recipient.unlock_funder!(@funders[0])
    @recipient.unlock_funder!(@funders[1])
    @recipient.unlock_funder!(@funders[2])
    @recipient.unlock_funder!(@funders[3])

    visit "/comparison/#{@funders[4].slug}"

    assert_equal "/comparison/#{@funders[4].slug}/gateway", current_path
    assert page.has_content?("You can only unlock 4 funders at the moment...")
  end

end
