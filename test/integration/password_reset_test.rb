require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest

  setup do
    @user = create(:user)
    ActionMailer::Base.deliveries = []
  end

  test 'clicking forgot password redirects to reset password page' do
    visit sign_in_path
    click_link('Forgot Password?')
    assert_equal new_password_reset_path, current_path
  end

  test 'reset password page has has link to correct faq' do
    visit new_password_reset_path
    assert_equal faq_path(anchor: 'reset-password'), find('.faq-link')[:href]
  end

  test 'correct email triggers password reset email' do
    assert_equal 0, ActionMailer::Base.deliveries.size
    visit new_password_reset_path
    fill_in('user_email', with: @user.user_email)
    click_button('Reset password')
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal sign_in_path, current_path
  end

  test 'incorrect email does not trigger password reset email' do
    assert_equal 0, ActionMailer::Base.deliveries.size
    visit new_password_reset_path
    fill_in('user_email', with: 'random@email.com')
    click_button('Reset password')
    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_equal sign_in_path, current_path
  end

  test 'set new password page has link to correct faq' do
    visit new_password_reset_path
    fill_in('user_email', with: @user.user_email)
    click_button('Reset password')
    assert_equal sign_in_path, current_path
    visit edit_password_reset_path(User.last.password_reset_token)
    assert_equal faq_path(anchor: 'set-password'), find('.faq-link')[:href]
  end

end
