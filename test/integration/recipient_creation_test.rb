require 'test_helper'

class RecipientCreationTest < ActionDispatch::IntegrationTest

  def full_form(state)
    within('#new_recipient') do
      select(state, from: 'recipient_org_type')
      fill_in('recipient_name', with: 'ACME')
      Capybara.match = :first
      select('United Kingdom', from: 'recipient_country')
      select(Organisation::OPERATING_FOR[0][0], from: 'recipient_operating_for')
      select(Organisation::INCOME[0][0], from: 'recipient_income')
      select(Organisation::EMPLOYEES[0][0], from: 'recipient_employees')
      select(Organisation::EMPLOYEES[0][0], from: 'recipient_volunteers')
      case state
      when 'A registered charity'
        fill_in('recipient_charity_number', with: '1161998')
      when 'A registered company'
        fill_in('recipient_company_number', with: '09544506')
      when 'A registered charity & company'
        fill_in('recipient_charity_number', with: '1161998')
        fill_in('recipient_company_number', with: '09544506')
      else
        fill_in('recipient_street_address', with: 'London Road')
      end
    end
  end

  def complete_form_for(state)
    create_and_auth_user!
    visit signup_organisation_path
    full_form(state)
    click_button('Next')

    assert_equal new_recipient_profile_path(Recipient.first), current_path
  end

  # test 'you get redirected when visiting the page when not signed in' do
  #   visit signup_organisation_path
  #   assert_equal sign_in_path, current_path
  # end
  #
  # test 'if you are signed in and you have an organisation you get redirected to new profile path' do
  #   @recipient = create(:recipient)
  #   create_and_auth_user!(organisation: @recipient)
  #   assert @user.organisation.present?
  #   visit signup_organisation_path
  #   assert_equal new_recipient_profile_path(@recipient), current_path
  # end
  #
  # test 'if you are signed in and have no organisation you can see the organisation page' do
  #   create_and_auth_user!
  #   assert_not @user.organisation.present?
  #   visit signup_organisation_path
  #   assert_equal signup_organisation_path, current_path
  # end
  #
  # test 'filling in form correctly submits, saves record and redirects to correct page' do
  #   create_and_auth_user!
  #   visit signup_organisation_path
  #   full_form('An unregistered organisation OR project')
  #   click_button('Next')
  #   assert_equal new_recipient_profile_path(Recipient.first), current_path
  #   assert page.has_content?('Target')
  # end
  #
  # test 'filling form incorrectly causes validation to trigger' do
  #   create_and_auth_user!
  #   visit signup_organisation_path
  #
  #   click_button('Next')
  #   assert_equal signup_organisation_path, current_path
  #   assert page.has_content?("can't be blank")
  # end
  #
  # test 'correct fields required for org type 1' do
  #   complete_form_for('A registered charity')
  # end
  #
  # test 'correct fields required for org type 2' do
  #   complete_form_for('A registered company')
  # end
  #
  # test 'correct fields required for org type 3' do
  #   complete_form_for('A registered charity & company')
  # end
  #
  # test 'charity with company number found changes org type' do
  #   create_and_auth_user!
  #   visit signup_organisation_path
  #   full_form('A registered charity')
  #   click_button('Next')
  #
  #   assert_equal new_recipient_profile_path(Recipient.first), current_path
  #   assert_equal 3, Recipient.first.org_type
  # end

  def create_user(charity_number)
    visit signup_user_path
    within('#new_user') do
      fill_in('user_first_name', with: 'Joe')
      fill_in('user_last_name', with: 'Bloggs')
      select(Organisation::ORG_TYPE[2][0], from: 'user_org_type')
      fill_in('user_charity_number', with: charity_number)
      fill_in('user_user_email', with: 'test@test.com')
      fill_in('user_password', with: 'password111')
    end
    click_button('Create an account')
  end

  test 'valid scraped recipient redirected to new proposal' do
    create_user('326568')
    assert_equal new_recipient_proposal_path(User.last.organisation), current_path
  end

  test 'invalid scraped recipient has to compelte missing fields' do
    create_user('1161998')
    assert_equal signup_organisation_path, current_path
    within('#new_recipient') do
      select(Organisation::INCOME[0][0], from: 'recipient_income')
      select(Organisation::EMPLOYEES[0][0], from: 'recipient_employees')
      select(Organisation::EMPLOYEES[0][0], from: 'recipient_volunteers')
    end
    click_button('Next')
    assert_equal new_recipient_proposal_path(User.last.organisation), current_path
  end

  test 'form cleared when org_type changes' do
    # refactor javascript testing
    # create_and_auth_user!
    # visit signup_organisation_path
    # within('#new_recipient') do
    #   select('A new project OR unincorporated association', from: 'recipient_org_type')
    #   fill_in('recipient_name', with: 'ACME')
    # end
    # click_button('Next')
    # within('#new_recipient') do
    #   select('Other', from: 'recipient_org_type')
    # end
    # assert_equal '', find("#recipient_name")[:value]
  end

  test 'clicking find scrapes data' do
    # refactor javascript testing
  end

end
