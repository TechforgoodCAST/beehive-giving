require 'test_helper'

class RecipientDashboardTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
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

    create_and_auth_user!(:organisation => @funder, :role => 'Funder')

    visit "/organisation/acme"
    assert_equal "/organisation/acme", current_path

    visit "/organisation/#{@recipient2.slug}"
    assert_equal "/organisation/#{@recipient2.slug}", current_path
  end

  test "recipient is directed to gateway for locked funders" do
    @profile = create(:profile, :organisation => @recipient)

    create_and_auth_user!(:organisation => @recipient)

    visit recipient_comparison_path(@funder)
    assert_equal recipient_comparison_gateway_path(@funder), current_path
  end

  test "recipient can see unlocked link on funders index for an unlocked funder" do
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    @recipient.unlock_funder!(@funder)

    visit funders_path
    assert_not page.has_content?('See how you compare (Locked)')
  end

end
