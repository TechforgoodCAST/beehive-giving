require 'test_helper'

class RecipientOnboardingTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  test 'Incomplete organisation creation redirects to organisation creation page' do
    create_and_auth_user!
    visit root_path
    assert_equal signup_organisation_path, current_path
  end

  test 'Incomplete profile creation redirects to profile creation page' do
    create_and_auth_user!(organisation: @recipient)
    visit root_path
    assert_equal new_recipient_profile_path(@recipient), current_path
  end

  test 'Incomplete profile update redirects to profile update page' do
    create_and_auth_user!(organisation: @recipient)
    create(:country) # For gon.countryName
    @profile = create(:incomplete_profile, organisation: @recipient)
    visit root_path
    assert_equal edit_recipient_profile_path(@recipient, @profile), current_path
  end

  test 'Complete registration redirects to funder recommendation page' do
    create_and_auth_user!(organisation: @recipient)
    @profile = create(:profile, organisation: @recipient, state: 'complete')
    visit root_path
    assert_equal recommended_funders_path, current_path
  end

end
