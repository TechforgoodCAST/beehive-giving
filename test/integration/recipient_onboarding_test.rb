require 'test_helper'

class RecipientOnboardingTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    create(:country)
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

  test 'Complete registration redirects to funder recommendation page' do
    create_and_auth_user!(organisation: @recipient)
    @initial_proposal = create(:initial_proposal, recipient: @recipient)
    visit root_path
    assert_equal recommended_funders_path, current_path
  end

end
