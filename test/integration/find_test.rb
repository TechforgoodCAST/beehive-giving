require 'test_helper'

class FindTest < ActionDispatch::IntegrationTest

  setup do
    create_and_auth_user!
    visit '/find'
  end

  test 'Find page should have form' do
    assert page.has_content?("England")
    assert page.has_css?("#uk_charity")
  end

  test 'root path for Find is organisation page' do
    find(:css, '.logo.uk-hidden-small').click
    assert_equal '/your-organisation', current_path
  end

  test "Find page with no params renders find page" do
    click_button('Next')
    assert_equal '/find', current_path
  end

  test "Find form with 'No' redirects to organisation form" do
    select('No', from: 'uk_charity')
    click_button('Next')
    assert_equal '/your-organisation', current_path
  end

  test "Find form with 'Yes', and without charity number renders find page" do
    select('Yes', from: 'uk_charity')
    click_button('Next')
    assert_equal '/find', current_path
  end

  test "Find form with invalid charity redirects to organisation page and shows correct params" do
    select('Yes', from: 'uk_charity')
    fill_in('charity_number', with: '123')
    click_button('Next')
    assert_equal '/your-organisation', current_path
    assert_equal nil, find_field('recipient[name]').value
    assert_equal 'true', find_field('recipient[registered]').value
    assert_equal '123', find_field('recipient[charity_number]').value
  end

  test "Find form with valid charity redirects to organisation page and shows correct params" do
    select('Yes', from: 'uk_charity')
    fill_in('charity_number', with: '1151106')
    click_button('Next')
    assert_equal '/your-organisation', current_path
    assert_equal 'The Big House Theatre Company', find_field('recipient[name]').value
  end

  test "Skip button redirects to organisation page and clears params" do
    select('Yes', from: 'uk_charity')
    fill_in('charity_number', with: '1151106')
    click_button('Next')

    click_link('Find your organisation')

    click_link('Skip this step')
    assert_equal '/your-organisation', current_path
    assert_equal nil, find_field('recipient[name]').value
    assert_equal "", find_field('recipient[registered]').value
    assert_equal nil, find_field('recipient[charity_number]').value
  end

end
