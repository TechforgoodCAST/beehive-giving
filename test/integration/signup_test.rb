require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest

  test 'filling in landing page form with incorrect info should not submit' do
    visit signup_user_path
    within('#new_user') do
      fill_in('user_first_name', with: 'Joe')
      fill_in('user_user_email', with: 'testnotanemail')
      fill_in('user_password', with: 'password111')
    end
    click_button('Create an account')
    assert_equal signup_user_path, current_path
    assert page.has_content?("Can't be blank")
  end

  test 'charity has to provide charity number that triggers scrape' do
    visit signup_user_path
    fill_in_form(2, false)
    click_button('Create an account')
    assert_equal signup_user_path, current_path

    fill_in_form(2)
    click_button('Create an account')

    # scrape triggerd for valid charity number
    assert_equal '1161998', find("#recipient_charity_number")[:value]
    assert_equal 'Centre For The Acceleration Of Social Technology', find("#recipient_name")[:value]
  end

  test 'company had to provide company number that triggers scrape' do
    visit signup_user_path
    fill_in_form(3, false)
    click_button('Create an account')
    assert_equal signup_user_path, current_path

    fill_in_form(3)
    click_button('Create an account')

    # scrape triggerd for valid company number
    assert_equal '09544506', find("#recipient_company_number")[:value]
    assert_equal 'Centre For The Acceleration Of Social Technology', find("#recipient_name")[:value]
  end

  test 'both has to provide both numbers that triggers scrape' do
    visit signup_user_path
    fill_in_form(4, false)
    click_button('Create an account')
    assert_equal signup_user_path, current_path

    fill_in_form(4)
    click_button('Create an account')

    # scrape triggerd for valid charity and company number
    assert_equal '1161998', find("#recipient_charity_number")[:value]
    assert_equal '09544506', find("#recipient_company_number")[:value]
    assert_equal 'Centre For The Acceleration Of Social Technology', find("#recipient_name")[:value]
  end

  test 'other has to provide minimum information' do
    visit signup_user_path
    fill_in_form(5)
    click_button('Create an account')

    # user org_type param transfered to new organisation form
    assert_equal Organisation::ORG_TYPE[5][0], find("#recipient_org_type option[selected='selected']").text
  end

end
