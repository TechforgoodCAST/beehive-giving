require 'test_helper'

class OrganisationCreationTest < ActionDispatch::IntegrationTest

  setup do
    expire_cookies
  end

  def create_and_auth_user!(opts = {})
    @user = create(:user, opts)
    create_cookie(:auth_token, @user.auth_token)
  end

  test 'You get redirected when visiting the page when not signed in' do
    visit '/your-organisation'
    assert_equal current_path, '/welcome'
  end

  test 'if you are signed in and you have an organisation you get redirected your dashboard' do
    @recipient = create(:recipient)
    create_and_auth_user!(:organisation => @recipient)
    visit '/your-organisation'
    assert_equal '/dashboard', current_path
  end

  test 'if you are signed in and have no organisation you can see the organisation page' do
    create_and_auth_user!
    assert_equal @user.organisation, nil
    visit '/your-organisation'
    assert_equal '/your-organisation', current_path
  end

  test 'filling in form correctly submits, saves record and redirects to correct page' do
    @recipient = create(:recipient)
    create_and_auth_user!
    visit '/your-organisation'
    within("#new_recipient") do
      fill_in("recipient_name", :with => @recipient.name)
      fill_in("recipient_mission", :with => @recipient.mission)
      fill_in("recipient_contact_number", :with => @recipient.contact_number)
      fill_in("recipient_website", :with => @recipient.website)
      fill_in("recipient_street_address", :with => @recipient.street_address)
      fill_in("recipient_city", :with => @recipient.city)
      fill_in("recipient_region", :with => @recipient.region)
      fill_in("recipient_postal_code", :with => @recipient.postal_code)
      fill_in("recipient_charity_number", :with => 123)
      fill_in("recipient_company_number", :with => 123)
      select('Yes', :from => "registered")
      select(@recipient.country, :from => "recipient_country")
      select(@recipient.founded_on.day, :from => "recipient_founded_on_3i")
      select(@recipient.founded_on.strftime("%-d"), :from => "recipient_founded_on_3i")
      select(@recipient.founded_on.strftime("%B"), :from => "recipient_founded_on_2i")
      select(@recipient.founded_on.strftime("%Y"), :from => "recipient_founded_on_1i")
      select(@recipient.registered_on.strftime("%-d"), :from => "recipient_registered_on_3i")
      select(@recipient.registered_on.strftime("%B"), :from => "recipient_registered_on_2i")
      select(@recipient.registered_on.strftime("%Y"), :from => "recipient_registered_on_1i")
    end
    click_button('Next')
    assert_equal '/your-profile', current_path
    assert page.has_content?("2015 profile")
  end

  test 'filling form incorrectly causes validation to trigger' do
    create_and_auth_user!
    visit '/your-organisation'
    within("#new_recipient") do
      fill_in("recipient_contact_number", :with => 'not an number')
      fill_in("recipient_website", :with => 'bbbbb')
      fill_in("recipient_street_address", :with => '')
      fill_in("recipient_city", :with => '')
    end
    click_button('Next')
    assert_equal '/your-organisation', current_path
    assert page.has_content?("can't be blank")
  end
end
