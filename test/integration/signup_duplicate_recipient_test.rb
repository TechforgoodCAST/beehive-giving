require 'test_helper'

class SignupDuplicateRecipientTest < ActionDispatch::IntegrationTest

  setup do
    create(:admin_user)
    seed_test_db
    ActionMailer::Base.deliveries = []
    @recipient = create(:recipient)
    create_and_auth_user!
  end

  test 'signing up a duplicate organisation will redirect' do
    assert_equal @user.organisation, nil
    assert_equal true, @user.authorised
    visit signup_organisation_path
    assert_equal signup_organisation_path, current_path
    within('#new_recipient') do
      select('A registered charity & company', from: 'recipient_org_type')
      fill_in('recipient_name', with: 'ACME')
      Capybara.match = :first
      select('United Kingdom', from: 'recipient_country')
      fill_in('recipient_charity_number', with: @recipient.charity_number)
      fill_in('recipient_company_number', with: @recipient.company_number)
    end
    click_button('Next')
    assert_equal unauthorised_path, current_path
    assert_equal 1, User.count
    assert_equal false, User.last.authorised
  end

  # refactor
  test 'sigining in a duplicate charity will redirect' do
    @recipient.destroy
    @recipient = create(:recipient, org_type: 1, company_number: '')
    visit signup_organisation_path
    within('#new_recipient') do
      select('A registered charity', from: 'recipient_org_type')
      fill_in('recipient_name', with: 'ACME')
      Capybara.match = :first
      select('United Kingdom', from: 'recipient_country')
      fill_in('recipient_charity_number', with: @recipient.charity_number)
    end
    click_button('Next')
    assert_equal unauthorised_path, current_path
  end

  # refactor
  test 'sigining in a duplicate company will redirect' do
    @recipient.destroy
    @recipient = create(:recipient, org_type: 2, charity_number: nil)
    visit signup_organisation_path
    within('#new_recipient') do
      select('A registered company', from: 'recipient_org_type')
      fill_in('recipient_name', with: 'ACME')
      Capybara.match = :first
      select('United Kingdom', from: 'recipient_country')
      fill_in('recipient_company_number', with: @recipient.company_number)
    end
    click_button('Next')
    assert_equal unauthorised_path, current_path
  end

  test 'user will be blocked from accessing other pages' do
    @user.lock_access_to_organisation(@recipient)
    assert_equal false, @user.authorised
    visit signup_organisation_path
    assert_equal unauthorised_path, current_path
    visit faq_path
    assert_equal faq_path, current_path
  end

  test 'mailer will be sent to admin if duplicate organisation found' do
    assert_equal 0, ActionMailer::Base.deliveries.size
    @user.lock_access_to_organisation(@recipient)
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'clicking link in email authorises user and triggers email' do
    assert_equal 0, ActionMailer::Base.deliveries.size
    @user.lock_access_to_organisation(@recipient)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal false, User.last.authorised
    visit grant_access_path(@user.unlock_token)
    assert_equal granted_access_path(@user.unlock_token), current_path
    assert_equal 1, User.count
    assert_equal true, User.last.authorised
    assert_equal 2, ActionMailer::Base.deliveries.size
    visit signup_organisation_path
    assert_equal new_recipient_proposal_path(@user.organisation), current_path
  end

  test 'once authorised redirected from unauthorised path' do
    visit unauthorised_path
    assert_equal signup_organisation_path, current_path
  end

end
