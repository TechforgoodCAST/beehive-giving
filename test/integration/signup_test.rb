require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest

  setup do

  end

  test 'Landing page should have sign up form' do
    visit signup_user_path
    assert page.has_content?('Work or volunteer for a non-profit?')
    assert page.has_css?('form#new_user')
  end

  test 'Filling in landing page form with correct info redirects to new organisation page' do
    visit signup_user_path
    within('#new_user') do
      fill_in('user_first_name', :with => 'Joe')
      fill_in('user_last_name', :with => 'Bloggs')
      select(User::JOB_ROLES.first, :from => 'user_job_role')
      fill_in('user_user_email', :with => 'test@test.com')
      fill_in('user_password', :with => 'password111')
      check('user_agree_to_terms')
    end
    click_button('Create an account')
    assert_equal signup_organisation_path, current_path
    assert page.has_content?('Welcome to Beehive')
  end

  test 'Filling in landing page form with incorrect info should not submit' do
    visit signup_user_path
    within('#new_user') do
      fill_in('user_first_name', :with => 'Joe')
      fill_in('user_user_email', :with => 'testnotanemail')
      fill_in('user_password', :with => 'password111')
    end
    click_button('Create an account')
    assert_equal signup_user_path, current_path
    assert page.has_content?("can't be blank")
  end

  test 'user cannot sign up if declares no organisation' do
    visit signup_user_path
    within('#new_user') do
      fill_in('user_first_name', :with => 'Joe')
      fill_in('user_last_name', :with => 'Bloggs')
      select("None, I don't work/volunteer for a non-profit", :from => 'user_job_role')
      fill_in('user_user_email', :with => 'test@test.com')
      fill_in('user_password', :with => 'password111')
      check('user_agree_to_terms')
    end
    click_button('Create an account')
    assert_equal signup_user_path, current_path
  end

end
