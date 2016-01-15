require 'test_helper'

class FunderNavigationTest < ActionDispatch::IntegrationTest

  setup do
    @user = create(:user, role: 'Funder')
  end

  # test 'signing in redirects to recent proposals' do
  #   visit sign_in_path
  #   within('#sign-in') do
  #     fill_in('email', with: @user.user_email)
  #     fill_in('password', with: @user.password)
  #   end
  #   click_button('Sign in')
  #   assert_equal funder_recent_path, current_path
  #   assert false
  # end

end
