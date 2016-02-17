require 'test_helper'

class OrganisationCreationTest < ActionDispatch::IntegrationTest

  def full_form(state)
    within('#new_recipient') do
      select(state, from: 'recipient_org_type')
      fill_in('recipient_name', with: 'ACME')
      Capybara.match = :first
      select('United Kingdom', from: 'recipient_country')
      select(Date.today.strftime('%B'), from: 'recipient_founded_on_2i')
      select(Date.today.strftime('%Y'), from: 'recipient_founded_on_1i')
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

    # scrape triggerd for valid charity number
    assert_equal 'Centre For The Acceleration Of Social Technology', find("#recipient_name")[:value]

    # complete missing data and submit
    within('#new_recipient') do
      select(find("#recipient_registered_on_2i option[selected='selected']").text, from: 'recipient_founded_on_2i')
      select(find("#recipient_registered_on_1i option[selected='selected']").text, from: 'recipient_founded_on_1i')
    end
    click_button('Next')

    assert_equal new_recipient_profile_path(Recipient.first), current_path
  end

  test 'you get redirected when visiting the page when not signed in' do
    visit signup_organisation_path
    assert_equal signup_user_path, current_path
  end

  test 'if you are signed in and you have an organisation you get redirected to new profile path' do
    @recipient = create(:recipient)
    create_and_auth_user!(organisation: @recipient)
    assert @user.organisation.present?
    visit signup_organisation_path
    assert_equal new_recipient_profile_path(@recipient), current_path
  end

  test 'if you are signed in and have no organisation you can see the organisation page' do
    create_and_auth_user!
    assert_not @user.organisation.present?
    visit signup_organisation_path
    assert_equal signup_organisation_path, current_path
  end

  test 'filling in form correctly submits, saves record and redirects to correct page' do
    create_and_auth_user!
    visit signup_organisation_path
    full_form('A new project OR unincorporated association')
    click_button('Next')
    assert_equal new_recipient_profile_path(Recipient.first), current_path
    assert page.has_content?('Target')
  end

  test 'filling form incorrectly causes validation to trigger' do
    create_and_auth_user!
    visit signup_organisation_path

    click_button('Next')
    assert_equal signup_organisation_path, current_path
    assert page.has_content?("can't be blank")
  end

  test 'unregistered organistion only needs founded on' do
    create_and_auth_user!
    visit signup_organisation_path
    full_form('Other')
    click_button('Next')
    assert_equal new_recipient_profile_path(Recipient.first), current_path
    assert page.has_content?('Target')
    assert Recipient.first.registered_on.nil?
  end

  test 'correct fields required for org type 1' do
    complete_form_for('A registered charity')
  end

  test 'correct fields required for org type 2' do
    complete_form_for('A registered company')
  end

  test 'correct fields required for org type 3' do
    complete_form_for('A registered charity & company')
  end

  test 'charity with company number found changes org type' do
    create_and_auth_user!
    visit signup_organisation_path
    full_form('A registered charity')
    click_button('Next')

    assert_equal '3', find("#recipient_org_type")[:value]
    assert_equal '09544506', find("#recipient_company_number")[:value]
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
