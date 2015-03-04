require 'test_helper'

class RecipientDashboardTest < ActionDispatch::IntegrationTest
  setup do

  end

  test 'dashboard is locked for user with no profiles' do
    @recipient = create(:recipient)
    3.times do
      @funder = create(:funder, :active_on_beehive => true)
    end
    create_and_auth_user!(:organisation => @recipient)
    visit '/dashboard'
    assert page.has_content?("See how you compare (Locked)")
    assert_equal all(".uk-icon-lock").length, 3
  end

  # page does contain 'See how you compare'
  # page contains class for lock icon
  # page opens model when click 'see how you compare'
  # modal contains 'unlock' or 'pay'


  # test if a recipient has one profile then the first funder is unlocked
  # test recipient can only unlock 3 funders
  # test dashboard has link to edit organisation
  # test dashboard has link to edit profiles
end
