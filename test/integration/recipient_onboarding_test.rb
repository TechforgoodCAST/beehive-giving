require 'test_helper'

class RecipientOnboardingTest < ActionDispatch::IntegrationTest

  setup do
    seed_test_db
    @recipient = create(:recipient)
  end

  test 'incomplete organisation creation redirects to organisation creation page' do
    create_and_auth_user!
    visit root_path
    assert_equal signup_organisation_path, current_path
  end

  test 'incomplete proposal creation redirects to proposal creation page' do
    create_and_auth_user!(organisation: @recipient)
    visit root_path
    assert_equal new_recipient_proposal_path(@recipient), current_path
  end

  test 'complete registration redirects to funder recommendation page' do
    create_and_auth_user!(organisation: @recipient)
    create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts)
    visit root_path
    assert_equal recommended_funders_path, current_path
  end

end
