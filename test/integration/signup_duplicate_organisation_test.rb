require 'test_helper'

class SignupDuplicateOrganisationTest < ActionDispatch::IntegrationTest

  setup do
    ActionMailer::Base.deliveries = []
    @organisation = create(:organisation)
    create_and_auth_user!
  end

  test 'Signing up a duplicate organisation will redirect' do
    assert_equal @user.organisation, nil
    assert_equal true, @user.authorised
    visit signup_organisation_path
    assert_equal signup_organisation_path, current_path
    within('#new_recipient') do
      select('A registered charity & company', from: 'recipient_org_type')
      fill_in('recipient_name', with: 'ACME')
      Capybara.match = :first
      select('United Kingdom', from: 'recipient_country')
      select(Date.today.strftime('%B'), from: 'recipient_founded_on_2i')
      select(Date.today.strftime('%Y'), from: 'recipient_founded_on_1i')
      fill_in('recipient_charity_number', with: @organisation.charity_number)
      fill_in('recipient_company_number', with: @organisation.company_number)
    end
    click_button('Next')
    assert_equal unauthorised_path, current_path
    assert_equal 1, User.count
    assert_equal false, User.last.authorised
  end

  test 'User will be blocked from accessing other pages' do
    @user.lock_access_to_organisation(@organisation)
    assert_equal false, @user.authorised
    visit signup_organisation_path
    assert_equal unauthorised_path, current_path
    visit faq_path
    assert_equal faq_path, current_path
  end

  test 'Mailer will be sent to admin if duplicate organisation found' do
    assert_equal 0, ActionMailer::Base.deliveries.size
    @user.lock_access_to_organisation(@organisation)
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'Clicking link in email authorises user and triggers email' do
    assert_equal 0, ActionMailer::Base.deliveries.size
    @user.lock_access_to_organisation(@organisation)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal false, User.last.authorised
    visit grant_access_path(@user.unlock_token)
    assert_equal granted_access_path(@user.unlock_token), current_path
    assert_equal 1, User.count
    assert_equal true, User.last.authorised
    assert_equal 2, ActionMailer::Base.deliveries.size
    visit signup_organisation_path
    assert_equal new_recipient_profile_path(@user.organisation), current_path
  end

end
