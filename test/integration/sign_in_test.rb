require 'test_helper'

class SignInTest < ActionDispatch::IntegrationTest

  setup do

  end

  test 'Clicking sign in navbar redirects to sign in page' do
    visit root_path
    click_button('Sign in')
    assert_equal sign_in_path, current_path
  end

  test 'Sign in page should have sign in form' do

  end

  test 'Valid details redirect to funders path' do

  end

  test 'Invalid details render sign up page with message' do

  end

end
