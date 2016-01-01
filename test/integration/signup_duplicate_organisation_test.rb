require 'test_helper'

class SignupDuplicateOrganisationTest < ActionDispatch::IntegrationTest
  
  setup do
    @organisation = create(:organisation) # create an organisation
    @user = create(:user)
  end

  test 'Signing up a duplicate organisation will redirect' do
    char_num = @organisation.charity_number
    comp_num = @organisation.company_number
    create_and_auth_user!
    assert_equal @user.organisation, nil
    visit signup_organisation_path
    within("#new_recipient") do
      fill_in("recipient_name", :with => 'ACME')
      Capybara.match = :first
      select("United Kingdom", :from => "recipient_country")
      select(Date.today.strftime("%B"), :from => "recipient_founded_on_2i")
      select(Date.today.strftime("%Y"), :from => "recipient_founded_on_1i")
      select('Yes', :from => "registered")
      fill_in("recipient_charity_number", :with => char_num)
      fill_in("recipient_company_number", :with => comp_num)
      select(Date.today.strftime("%B"), :from => "recipient_registered_on_2i")
      select(Date.today.strftime("%Y"), :from => "recipient_registered_on_1i")
    end
  end

  test 'User will be blocked from accessing other pages' do
  end

  test 'Mailer will be sent to relevant organisation' do
  end

end
