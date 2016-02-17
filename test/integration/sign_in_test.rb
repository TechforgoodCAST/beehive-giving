require 'test_helper'

class SignInTest < ActionDispatch::IntegrationTest

  setup do
    @user = create(:user)
  end

  test 'Clicking sign in navbar redirects to sign in page' do
    visit root_path
    click_link('Sign in')
    assert_equal sign_in_path, current_path
  end

  test 'Sign in page should have sign in form' do
    visit sign_in_path
    assert page.has_content?('Sign in to continue')
  end

  test 'Valid details redirect to funders path' do
    visit sign_in_path
    within('#sign-in') do
      fill_in('email', with: @user.user_email)
      fill_in('password', with: @user.password)
    end
    click_button('Sign in')
    assert_equal signup_organisation_path, current_path
  end

  test 'Invalid details render sign up page with message' do
    visit sign_in_path
    within('#sign-in') do
      fill_in('email', with: @user.user_email)
      fill_in('password', with: 'incorrect')
    end
    click_button('Sign in')
    assert_equal sign_in_path, current_path
    assert page.has_content?('Oops!')
  end

  test 'If signed in redirected to root path' do
    create_cookie(:auth_token, @user.auth_token)
    visit sign_in_path
    assert_equal signup_organisation_path, current_path
  end

  test 'User email is downcased' do
    visit sign_in_path
    within('#sign-in') do
      fill_in('email', with: @user.user_email.upcase)
      fill_in('password', with: @user.password)
    end
    click_button('Sign in')
    assert_equal signup_organisation_path, current_path
  end

end
