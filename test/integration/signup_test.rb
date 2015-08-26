require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest

  setup do

  end

  test 'Landing page should have sign up form' do
    visit '/'
    assert page.has_content?("Do you work for a")
    assert page.has_css?("form#new_user")
  end

  test 'Filling in landing page form with correct info redirects to new organisation page' do
    visit '/'
    within("#new_user") do
      fill_in("user_first_name", :with => "Joe")
      fill_in("user_last_name", :with => "Bloggs")
      select(User::JOB_ROLES.sample, :from => "user_job_role")
      fill_in("user_user_email", :with => "test@test.com")
      fill_in("user_password", :with => "password111")
      check("user_agree_to_terms")
    end
    click_button('Create an account')
    assert_equal signup_organisation_path, current_path
    assert page.has_content?('Last step')
  end

  test 'Filling in landing page form with incorrect info should not submit' do
    visit '/'
    within("#new_user") do
      fill_in("user_first_name", :with => "Joe")
      fill_in("user_user_email", :with => "testnotanemail")
      fill_in("user_password", :with => "password111")
    end
    click_button('Create an account')
    assert_equal current_path, '/welcome'
    assert page.has_content?("can't be blank")
  end

end
