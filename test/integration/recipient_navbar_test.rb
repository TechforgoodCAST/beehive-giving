require 'test_helper'

class RecipientNavbarTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  test 'logo click whilst unregistered sends to user#signup' do
    visit faq_path
    find(:css, '.logo').click
    assert_equal signup_user_path, current_path
  end

  test 'user creating profile has not navigation options' do
    create_and_auth_user!
    visit root_path
    assert_equal signup_organisation_path, current_path
    assert_not page.has_content?('Update profile')
    assert_not page.has_content?('Funding proposals')
    assert_not page.has_content?('Sign out')
  end

  test 'user with profile can navigate to edit profiles path' do
    create_and_auth_user!(organisation: @recipient)
    create(:profile, organisation: @recipient)
    visit recommended_funders_path
    assert_equal recommended_funders_path, current_path
    assert page.has_content?('Update profile')
    assert_not page.has_content?('Funding proposals')
    assert page.has_content?('Sign out')
  end

  test 'user with proposal can navigate to edit proposals path' do
    skip
    create_and_auth_user!(organisation: @recipient)
    create(:profile, organisation: @recipient)
    create(:proposal, recipient: @recipient)
    visit recommended_funders_path
    assert_equal recommended_funders_path, current_path
    assert page.has_content?('Update profile')
    assert page.has_content?('Funding proposals')
    assert page.has_content?('Sign out')
  end

end
