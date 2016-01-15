require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest

  test 'landing page should have sign up form' do
    visit signup_user_path
    assert page.has_content?('Sign up')
    assert page.has_css?('form#new_user')
  end

  def fill_in_form(state, fill=true)
    within('#new_user') do
      fill_in('user_first_name', with: 'Joe')
      fill_in('user_last_name', with: 'Bloggs')
      select(Organisation::ORG_TYPE[state][0], from: 'user_org_type')
      fill_in('user_user_email', with: 'test@test.com')
      fill_in('user_password', with: 'password111')
      check('user_agree_to_terms')

      fill_in('user_charity_number', with: '1161998') if state == 1 && fill || state == 3 && fill
      fill_in('user_company_number', with: '09544506') if state == 2 && fill || state == 3 && fill
    end
  end

  test 'filling in landing page form with correct info redirects to new organisation page' do
    visit signup_user_path
    fill_in_form(0)
    click_button('Create an account')
    assert_equal signup_organisation_path, current_path
    assert page.has_content?('Welcome to Beehive')

    # user org_type param transfered to new organisation form
    assert_equal Organisation::ORG_TYPE[0][0], find("#recipient_org_type option[selected='selected']").text
  end

  test 'filling in landing page form with incorrect info should not submit' do
    visit signup_user_path
    within('#new_user') do
      fill_in('user_first_name', with: 'Joe')
      fill_in('user_user_email', with: 'testnotanemail')
      fill_in('user_password', with: 'password111')
    end
    click_button('Create an account')
    assert_equal signup_user_path, current_path
    assert page.has_content?("can't be blank")
  end

  test 'charity has to provide charity number that triggers scrape' do
    visit signup_user_path
    fill_in_form(1, false)
    click_button('Create an account')
    assert_equal signup_user_path, current_path

    fill_in_form(1)
    click_button('Create an account')

    # scrape triggerd for valid charity number
    assert_equal '1161998', find("#recipient_charity_number")[:value]
    assert_equal 'Centre For The Acceleration Of Social Technology', find("#recipient_name")[:value]
  end

  test 'company had to provide company number that triggers scrape' do
    visit signup_user_path
    fill_in_form(2, false)
    click_button('Create an account')
    assert_equal signup_user_path, current_path

    fill_in_form(2)
    click_button('Create an account')

    # scrape triggerd for valid company number
    assert_equal '09544506', find("#recipient_company_number")[:value]
    assert_equal 'Centre For The Acceleration Of Social Technology', find("#recipient_name")[:value]
  end

  test 'both has to provide both numbers that triggers scrape' do
    visit signup_user_path
    fill_in_form(3, false)
    click_button('Create an account')
    assert_equal signup_user_path, current_path

    fill_in_form(3)
    click_button('Create an account')

    # scrape triggerd for valid charity and company number
    assert_equal '1161998', find("#recipient_charity_number")[:value]
    assert_equal '09544506', find("#recipient_company_number")[:value]
    assert_equal 'Centre For The Acceleration Of Social Technology', find("#recipient_name")[:value]
  end

  test 'other has to provide minimum information' do
    visit signup_user_path
    fill_in_form(4)
    click_button('Create an account')

    # user org_type param transfered to new organisation form
    assert_equal Organisation::ORG_TYPE[4][0], find("#recipient_org_type option[selected='selected']").text
  end

end
