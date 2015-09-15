require 'test_helper'

class OrganisationCreationTest < ActionDispatch::IntegrationTest

  test 'You get redirected when visiting the page when not signed in' do
    visit signup_organisation_path
    assert_equal signup_user_path, current_path
  end

  test 'if you are signed in and you have an organisation you get redirected to new profile path' do
    @recipient = create(:recipient)
    create_and_auth_user!(:organisation => @recipient)
    visit signup_organisation_path
    assert_equal funders_path, current_path
  end

  test 'if you are signed in and have no organisation you can see the organisation page' do
    create_and_auth_user!
    assert_equal @user.organisation, nil
    visit signup_organisation_path
    assert_equal signup_organisation_path, current_path
  end

  def full_form(registered)
    within("#new_recipient") do
      fill_in("recipient_name", :with => 'ACME')
      select('No', :from => "registered")
      Capybara.match = :first
      select("United Kingdom", :from => "recipient_country")
      select(Date.today.strftime("%B"), :from => "recipient_founded_on_2i")
      select(Date.today.strftime("%Y"), :from => "recipient_founded_on_1i")
      if registered
        select('Yes', :from => "registered")
        fill_in("recipient_charity_number", :with => 123)
        fill_in("recipient_company_number", :with => 123)
        select(Date.today.strftime("%B"), :from => "recipient_registered_on_2i")
        select(Date.today.strftime("%Y"), :from => "recipient_registered_on_1i")
      end
    end
  end

  test 'filling in form correctly submits, saves record and redirects to correct page' do
    create_and_auth_user!
    visit signup_organisation_path
    full_form(true)
    click_button('Continue')
    assert_equal new_recipient_profile_path(Recipient.first), current_path
    assert page.has_content?("Funders")
  end

  test 'filling form incorrectly causes validation to trigger' do
    create_and_auth_user!
    visit signup_organisation_path

    click_button('Continue')
    assert_equal signup_organisation_path, current_path
    assert page.has_content?("can't be blank")
  end

  test 'unregistered organistion only needs founded on' do
    create_and_auth_user!
    visit '/your-organisation'
    full_form(false)
    click_button('Continue')
    assert_equal new_recipient_profile_path(Recipient.first), current_path
    assert page.has_content?("Funders")
    assert Recipient.first.registered_on.nil?
  end

end
