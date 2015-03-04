require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest

  setup do

  end

  test 'Landing page should have sign up form' do
    visit '/'
    assert page.has_content?("Sign up today")
    assert page.has_css?("form#new_user")
  end

  test 'Filling in landing page form with correct info redirects to organisation page' do
    visit '/'
    within("#new_user") do
      fill_in("user_first_name", :with => "Joe")
      fill_in("user_last_name", :with => "Bloggs")
      fill_in("user_job_role", :with => "Founder")
      fill_in("user_user_email", :with => "test@test.com")
      fill_in("user_password", :with => "password111")
      fill_in("user_password_confirmation", :with => "password111")
    end
    click_button('Sign up')
    assert_equal current_path, '/your-organisation'
    assert page.has_content?("Organisation")
  end

  test 'Filling in landing page form with incorrect info should not submit' do
    visit '/'
    within("#new_user") do
      fill_in("user_first_name", :with => "Joe")
      fill_in("user_job_role", :with => "")
      fill_in("user_user_email", :with => "tesnotanemail")
      fill_in("user_password", :with => "password111")
      fill_in("user_password_confirmation", :with => "password112")
    end
    click_button('Sign up')
    assert_equal current_path, '/welcome'
    assert page.has_content?("can't be blank")
  end

end
